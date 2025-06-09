function ptg --description 'Send stdin or argument to Telegram'
    set -l who $argv[1]
    if test -z "$who"
        echo "Usage: ptg <who> [message|file]"
        return 1
    end

    # Check if config files exist
    if not test -f ~/.local/dotfiles/done_notify.fish
        echo "Error: done_notify.fish not found!"
        return 1
    end

    if not test -f ~/.local/dotfiles/telegram-ids.json
        echo "Error: telegram-ids.json not found!"
        return 1
    end

    # Load TELEGRAM_URL with better error handling
    set -l telegram_url (grep "set TELEGRAM_URL" ~/.local/dotfiles/done_notify.fish | string split "'" | string match "https://*")
    set -l base_url (string replace "sendMessage" "" $telegram_url)

    if test -z "$telegram_url"
        echo "Error: TELEGRAM_URL not found or invalid in done_notify.fish!"
        return 1
    end

    # Load chat ID from JSON with better error handling
    if not command -q jq
        echo "Error: jq is not installed. Please install it first."
        return 1
    end

    set -l chat_id (cat ~/.local/dotfiles/telegram-ids.json | jq -r --arg who "$who" '.[$who]' 2>/dev/null)

    if test -z "$chat_id" -o "$chat_id" = null
        echo "Error: Chat ID for '$who' not found in telegram-ids.json!"
        return 1
    end

    if isatty stdin
        echo "Reading from arguments..."
        # No stdin, check if a message was provided
        if test (count $argv) -ge 2
            # Check if argument is a file
            if test -f $argv[2]
                echo "Uploading file..."
                set -l file $argv[2]
                set -l abs_path (realpath $file)
                set -l caption (printf "📄 <b>File:</b> %s\n📍 <b>Path:</b> %s" (basename $file) $abs_path)

                set -l response (curl -s -X POST $base_url"sendDocument" \
                                                                                                                                            -F chat_id="$chat_id" \
                                                                                                                                            -F document=@"$file" \
                                                                                                                                            -F caption="$caption" \
                                                                                                                                            -F parse_mode="HTML" \
                                                                                                                                            --connect-timeout 10 \
                                                                                                                                            --max-time 30)

                if test $status -ne 0
                    echo "Error: Failed to connect to Telegram API!"
                    return 1
                end

                if not echo $response | jq -e '.ok' >/dev/null
                    echo "Error: Failed to send file: "(echo $response | jq -r '.description // "Unknown error"')
                    return 1
                end

                echo "✓ File successfully sent to '$who'."
                return 0
            else
                # Regular message
                set -l message (string join \n $argv[2..-1])
                set -l response (curl -s -X POST "$telegram_url" \
                                                                                                                                                -d chat_id="$chat_id" \
                                                                                                                                                --data-urlencode text="$message" \
                                                                                                                                                -d parse_mode="HTML" \
                                                                                                                                                --connect-timeout 10 \
                                                                                                                                                --max-time 30)

                if test $status -ne 0
                    echo "Error: Failed to connect to Telegram API!"
                    return 1
                end

                if not echo $response | jq -e '.ok' >/dev/null
                    echo "Error: Failed to send message: "(echo $response | jq -r '.description // "Unknown error"')
                    return 1
                end
            end
        else
            echo "Error: No input detected! Provide a message/file or pipe into ptg."
            return 1
        end
    else
        echo "Reading from stdin..."
        # Get the command that was piped
        sync_history
        set -l cmd (history --max 2 | head -n 1)
        # Save stdin to file
                set -l tmpfile (mktemp)
                set -l splitdir   (mktemp -d)

#         set -l tmpfile "/Users/behnam/tt.txt"
#         set -l splitdir /Users/behnam/tt_split

        # Create split directory if it doesn't exist
        #                         mkdir -p $splitdir

        # Add command at the top
        echo -e "\$ <b><u>$cmd</u></b>" > $tmpfile
        echo -e "\n=======================\n" >>$tmpfile
        echo -e "<pre>" >> $tmpfile

        cat >> $tmpfile
        echo -e "</pre>" >> $tmpfile

        # Split file into chunks
        split -b 3800 $tmpfile $splitdir/chunk_
        # find the very last chunk
        set -l last_chunk (ls $splitdir/chunk_* | sort | tail -n1)

        # Send each chunk
for chunk in $splitdir/chunk_*
    echo "Sending chunk "(basename $chunk)"..."

    # 1) First chunk: append closing </pre> if it’s not already there
    if test $chunk = "$splitdir/chunk_aa"; and not grep -q '</pre>' "$chunk"
        echo '</pre>' >> "$chunk"
    end

    # 2) Middle chunks: wrap in both <pre>…</pre>
    if test $chunk != "$splitdir/chunk_aa"; and test $chunk != "$last_chunk"
        echo '<pre>' | cat - "$chunk" > "$chunk.tmp"
        mv "$chunk.tmp" "$chunk"
        echo '</pre>' >> "$chunk"
    end

    # 3) Last chunk: prepend opening <pre> if it’s not already there
    if test $chunk = "$last_chunk"; and not grep -q '<pre>' "$chunk"
        echo '<pre>' | cat - "$chunk" > "$chunk.tmp"
        mv "$chunk.tmp" "$chunk"
    end
            set -l response (curl -s -X POST "$telegram_url" \
                                                                                                                            -d chat_id="$chat_id" \
                                                                                                                            --data-urlencode text="$(cat $chunk)" \
                                                                                                                            -d parse_mode="HTML" \
                                                                                                                            --connect-timeout 10 \
                                                                                                                            --max-time 30)

            if test $status -ne 0
                rm -rf $splitdir
                echo "Error: Failed to connect to Telegram API!"
                return 1
            end

            if not echo $response | jq -e '.ok' >/dev/null
                rm -rf $splitdir
                echo "Error: Failed to send chunk: "(echo $response | jq -r '.description // "Unknown error"')
                return 1
            end
        end

        # Clean up
        rm -rf $splitdir
    end

    echo "✓ Message successfully sent to '$who'."
end
