if status is-interactive
    # Commands to run in interactive sessions can go here
    source $HOME/.config/fish/conf.d/fifc.fish
    source $HOME/.config/fish/conf.d/forgit.plugin.fish
    fzf_configure_bindings
end

#test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

#kubectl completion fish | source


#set -x KUBECONFIG (ls ~/.kube/*.yaml | tr '\n' ':')

# Created by `pipx` on 2025-02-11 07:54:41
#set PATH $PATH /Users/behnam/.local/bin

# source /Users/behnam/.config/fish/conf.d/fifc.fish

# Fish:
# ~/.config/fish/config.fish:
# source /Users/behnam/.config/fish/conf.d/forgit.plugin.fish

