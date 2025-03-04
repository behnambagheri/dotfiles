if status is-interactive
    # Commands to run in interactive sessions can go here
    source ~/.config/fish/conf.d/fifc.fish
    source ~/.config/fish/conf.d/forgit.plugin.fish
end

if status is-login
    source ~/.config/fish/config.fish
    source ~/.config/fish/conf.d/fzf.fish

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

