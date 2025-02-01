function pastebin

curl -w '\n' -q -L --data-binary @- -o - https://paste.bea.sh/
end
