# ~/.config/fish/completions/krrd.fish

function __krrd_deployments
    if test -z "$argv"
        kubectl get deployments --context (kubectl config current-context) --namespace $(kubectl config view --minify -o jsonpath='{.contexts[0].context.namespace}') -o name | sed 's|^deployment.apps/||'
    else
        set namespace $argv[1]
        kubectl get deployments --context (kubectl config current-context) --namespace $namespace -o name | sed 's|^deployment.apps/||'
    end
end

function __krrd_namespaces
    kubectl get namespaces -o name | cut -d/ -f2
end

function __krrd_context
    kubectl config get-contexts -o name
end

# Complete --context
complete -c krrd -n "__fish_seen_subcommand_from --context" -f -a "(__krrd_context)" -d "Available contexts"

# Complete --namespace
complete -c krrd -n "__fish_seen_subcommand_from --namespace" -f -a "(__krrd_namespaces)" -d "Available namespaces"

# Complete --deployment
complete -c krrd -n "__fish_seen_subcommand_from --deployment" -f -a "(__krrd_deployments)" -d "Available deployments"

# Default: If no flag is provided, list deployments for the current context and namespace
complete -c krrd -f -a "(__krrd_deployments)" -d "Available deployments"

# Define behavior for krrd with --context, --namespace, and --deployment
complete -c krrd -f -a "--context --namespace --deployment" -d "Flags for krrd command"
