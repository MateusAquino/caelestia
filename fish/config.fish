if status is-interactive
    # Starship custom prompt
    starship init fish | source

    # Direnv + Zoxide
    command -v direnv &> /dev/null && direnv hook fish | source
    command -v zoxide &> /dev/null && zoxide init fish --cmd cd | source

    # Better ls
    alias ls='eza --icons --group-directories-first -1'
    alias gitrmb='git branch | cut -c 3- | gum choose --no-limit | xargs git branch -D'
    alias cwd='pwd'
    alias shell='env QSG_RENDER_LOOP=threaded QT_QUICK_CONTINUOUS_UPDATE=1 caelestia shell -d'

    # Abbrs
    abbr q 'exit'
    abbr c 'clear'
    abbr agit 'git add . && git'
    abbr agitc 'git add . && git commit -m'
    abbr gitam 'git commit --am'
    abbr agitam 'git add . && git commit --am'
    abbr mixes 'mix format && mix credo --strict & mix test'
    abbr mixest 'mix format && mix credo --strict & mix translate'

    abbr l 'ls'
    abbr ll 'ls -l'
    abbr la 'ls -a'
    abbr lla 'ls -la'
    abbr lsmnt 'duf'
    abbr lss 'dust'

    # Custom colours
    cat ~/.local/state/caelestia/sequences.txt 2> /dev/null

    # For jumping between prompts in foot terminal
    function mark_prompt_start --on-event fish_prompt
        echo -en "\e]133;A\e\\"
    end

    function s
        git fetch origin --prune
        git switch $argv
        git pull origin $argv
    end

    function cs
        s $argv
        sudo chown --recursive mafios ./
    end
end

eval (ssh-agent -c) > /dev/null
set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
set -Ux SSH_AGENT_PID $SSH_AGENT_PID
set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK

