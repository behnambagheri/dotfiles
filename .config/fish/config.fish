if status is-interactive
    # Commands to run in interactive sessions can go here
end

test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

kubectl completion fish | source


set -x KUBECONFIG (ls ~/.kube/*.yaml | tr '\n' ':')
