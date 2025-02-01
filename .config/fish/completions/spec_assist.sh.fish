# Define completion function for my_script
function _complete_spec_assist.sh
    set -l completions

    switch (commandline -cp)
        case --add-plan
            set completions "--repo"
            ;;
        case --delete-plan
            set completions "--repo"
            ;;
        case --repo
            # Implement completion for repository names here
            set completions "repo1" "repo2" "repo3"  # Example repository names
            ;;
    end

    complete --no-files --no-directories --command spec_assist.sh --arguments "$completions"
end

# Invoke the completion function
_complete_spec_assist.sh

