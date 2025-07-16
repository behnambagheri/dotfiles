function krrd
    # گرفتن انتخاب از fzf
    set selection (
        begin
            # چاپ هدر
            printf "%-20s %-20s %-45s %-7s %-10s\n" "CTX" "NAMESPACE" "NAME" "READY" "AGE"
            
            # مرور روی تمام contextها
            for ctx in (kubectl config get-contexts -o name)
                kubectl --context=$ctx get deployments --all-namespaces --no-headers \
                            | awk -v c=$ctx '{printf "%-20s %-20s %-45s %-7s %-10s\n", c,$1,$2,$3,$6}'
            end
        end \
                | column -t \
                | fzf --ansi \
                      --header-lines=1 \
                      --layout=reverse \
                      --prompt="🔍  Filter deployments > " \
                      --no-hscroll \
                      --preview="kubectl --context {1} -n {2} get deploy {3} -o wide" \
                      --preview-window=right:70%
    )
    
    # اگر چیزی انتخاب نشده بود، برگشت
    test -z "$selection"; and return 1
    
    # پارس کردن ctx، ns، و dep از انتخاب
    set ctx (echo $selection | awk '{print $1}')
    set ns  (echo $selection | awk '{print $2}')
    set dep (echo $selection | awk '{print $3}')
    
    # نشان دادن دستوری که قرار است اجرا شود
    echo "→ kubectl rollout restart --context $ctx --namespace $ns deployment $dep"
    
    # اجرای دستور kubectl برای ری‌استارت
    kubectl rollout restart --context $ctx --namespace $ns deployment/$dep
end
