function cdc
    set -l entries \
        "caelestia:~/Github/caelestia:Main Caelestia repo" \
        "caelestia-shell:~/.config/quickshell/caelestia:Caelestia quickshell config" \
        "caelestia-cli:~/Github/cli:Caelestia CLI repo"

    # --------------------------------------------

    function _print_list
        echo "Available directories:"
        for e in $entries
            set -l n (printf '%s\n' $e | awk -F: '{print $1}')
            set -l d (printf '%s\n' $e | awk -F: '{
                for(i=3;i<=NF;i++){ printf("%s%s",$i,(i<NF?":":"")) }
                printf "\n"
            }')
            printf "  %-18s %s\n" $n $d
        end
    end

    # Help
    if test (count $argv) -gt 0
        set -l a $argv[1]
        if contains -- $a -h --help help
            echo "Usage:"
            echo "  cdc           # interactive chooser (requires gum)"
            echo "  cdc <name>    # cd directly into directory"
            echo ""
            _print_list
            return 0
        end
    end

    # Direct jump
    if test (count $argv) -gt 0
        set -l target $argv[1]
        for e in $entries
            set -l n (printf '%s\n' $e | awk -F: '{print $1}')
            if test $n = $target
                set -l path (printf '%s\n' $e | awk -F: '{print $2}')
                set -l dir (eval echo $path)

                if test -d $dir
                    cd $dir
                    return 0
                else
                    echo "Directory does not exist: $dir"
                    return 1
                end
            end
        end

        echo "Unknown directory: '$target'"
        echo ""
        _print_list
        return 2
    end

    # Interactive chooser
    if not command -v gum >/dev/null
        echo "Error: 'gum' not found in PATH. Install it or run: cdc <name>"
        return 1
    end

    set -l display_lines
    for e in $entries
        set -l n (printf '%s\n' $e | awk -F: '{print $1}')
        set -l d (printf '%s\n' $e | awk -F: '{
            for(i=3;i<=NF;i++){ printf("%s%s",$i,(i<NF?":":"")) }
            printf "\n"
        }')
        set display_lines $display_lines "$n — $d"
    end

    set -l chosen (printf '%s\n' $display_lines | gum choose --header "Choose directory to cd into")
    if test -z "$chosen"
        return 1
    end

    set -l sel_name (printf '%s\n' "$chosen" | awk -F' — ' '{print $1}')

    for e in $entries
        set -l n (printf '%s\n' $e | awk -F: '{print $1}')
        if test $n = $sel_name
            set -l path (printf '%s\n' $e | awk -F: '{print $2}')
            set -l dir (eval echo $path)

            if test -d $dir
                cd $dir
                return 0
            else
                echo "Directory does not exist: $dir"
                return 1
            end
        end
    end

    echo "Selected entry not found (this should not happen)."
    return 3
end
