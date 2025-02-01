function fish_prompt
  # Cache the last command's exit status at the very beginning of the function
  set -l last_status $status

  sync_history


  # Calculate hostname once
  if not set -q __fish_prompt_hostname
    set -g __fish_prompt_hostname (uname -n | cut -d . -f 1)
  end

  # Set prompt character based on user
  if not set -q __fish_prompt_char
    switch (id -u)
      case 0
        set -g __fish_prompt_char '#'
      case '*'
        set -g __fish_prompt_char 'λ'
    end
  end

  if test (uname -n | cut -d . -f 1) = "Bagheri-MacBook-Pro"
#     set -l bagher hiiiiii
    set -g current_user bea
    set -g kubenv_current_cluster (kubectl config view --minify --output 'jsonpath={.contexts[0].context.cluster}' | cut -d'@' -f1)
    set -g kubenv_current_namespace (kubectl config view --minify --output 'jsonpath={.contexts[0].context.namespace}' | cut -d'@' -f1)
  else
    set -g current_user (whoami)
  end


  # Setup colors
  set -l hostcolor (set_color (uname -n | md5sum | cut -f1 -d' ' | tr -d '\n' | tail -c6))
  set -l normal (set_color normal)
  set -l white (set_color FFFFFF)
  set -l turquoise (set_color 5fdfff)
  set -l orange (set_color df5f00)
  set -l hotpink (set_color df005f)
  set -l blue (set_color blue)
  set -l limegreen (set_color 87ff00)
  set -l purple (set_color af5fff)
  set -l darkgreen (set_color 557C55)

  # Configure __fish_git_prompt
  set -g __fish_git_prompt_char_stateseparator ' '
  set -g __fish_git_prompt_color 5fdfff
  set -g __fish_git_prompt_color_flags df5f00
  set -g __fish_git_prompt_color_prefix white
  set -g __fish_git_prompt_color_suffix white
  set -g __fish_git_prompt_showdirtystate true
  set -g __fish_git_prompt_showuntrackedfiles true
  set -g __fish_git_prompt_showstashstate true
  set -g __fish_git_prompt_show_informative_status true

  # Kubernetes context

#   set -l current_user bea

  # Exit status with color
  set -l exit_color
  if test $last_status -eq 0
    set exit_color (set_color green)
  else
    set exit_color (set_color red)
  end

  ##
  ## Line 1
  ##
  echo -n $hostcolor'╭─'$hotpink$current_user$white' at '$orange$__fish_prompt_hostname$white' in '$limegreen(pwd | sed "s=$HOME=⌁=")$turquoise $white'['$purple$kubenv_current_namespace ''$blue'⎈ '$hotpink$kubenv_current_cluster''$white']'$white' ('$exit_color$last_status$white')'

  __fish_git_prompt " (%s)"
  echo

  ##
  ## Line 2
  ##
  echo -n $hostcolor'╰'

  # Disable virtualenv's default prompt
  set -g VIRTUAL_ENV_DISABLE_PROMPT true

  # Support for virtual environment name
  if set -q VIRTUAL_ENV
    echo -n "($turquoise"(basename "$VIRTUAL_ENV")"$white)"
  end

  ##
  ## Support for vi mode
  ##
  set -l lambdaViMode "$THEME_LAMBDA_VI_MODE"

  if test "$fish_key_bindings" = fish_vi_key_bindings
      or test "$fish_key_bindings" = fish_hybrid_key_bindings
    if test -z (string match -ri '^no|false|0$' $lambdaViMode)
      set_color --bold
      echo -n $white'─['
      switch $fish_bind_mode
        case default
          set_color red
          echo -n 'n'
        case insert
          set_color green
          echo -n 'i'
        case replace_one
          set_color green
          echo -n 'r'
        case replace
          set_color cyan
          echo -n 'r'
        case visual
          set_color magenta
          echo -n 'v'
      end
      echo -n $white']'
    end
  end

  ##
  ## Rest of the prompt
  ##
  echo -n $hostcolor'─'$white$__fish_prompt_char $normal
end