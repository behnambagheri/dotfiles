function git-commit-push
git commit -am  "Commit files: $(git diff --name-only| tr '\n' ' ')" && git push
end
