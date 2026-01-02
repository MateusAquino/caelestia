function config
    set -l entries \
        "shell:~/Github/caelestia/fish/config.fish:Fish shell config" \
        "terminal:~/Github/caelestia/foot/foot.ini:Foot terminal config" \
        "env:~/Github/caelestia/hypr/hyprland/env.conf:Environment Variables" \
        "hypr-vars:~/Github/caelestia/hypr/variables.conf:Hypr/variables.conf" \
        "hypr-conf:~/Github/caelestia/hypr/hyprland.conf:Hypr/hyprland.conf" \
        "hypr-execs:~/Github/caelestia/hypr/hyprland/execs.conf:Hypr/execs.conf" \
        "hypr-keybinds:~/Github/caelestia/hypr/hyprland/keybinds.conf:Hypr/keybinds.conf" \
        "hypr-input:~/Github/caelestia/hypr/hyprland/input.conf:Hypr/input.conf" \
        "starship:~/Github/caelestia/starship.toml:Starship theme config" \
        "fastfetch:~/Github/caelestia/fastfetch/config.jsonc:Fastfetch config"

    # --------------------------------------------

    # Helper: print available configs
    function _print_list
        echo "Available configs:"
        for e in $entries
            set -l n (printf '%s\n' $e | awk -F: '{print $1}')
            set -l d (printf '%s\n' $e | awk -F: '{
                for(i=3;i<=NF;i++){ printf("%s%s",$i,(i<NF?":":"")) }
                printf "\n"
            }')
            printf "  %-12s %s\n" $n $d
        end
    end

    # Help
    if test (count $argv) -gt 0
        set -l a $argv[1]
        if contains -- $a -h --help help
            echo "Usage:"
            echo "  config           # interactive chooser (requires gum)"
            echo "  config <name>    # open config directly (nano <file> or \$EDITOR/vi fallback)"
            echo ""
            _print_list
            return 0
        end
    end

    # Direct open if given a name
    if test (count $argv) -gt 0
        set -l target $argv[1]
        for e in $entries
            set -l n (printf '%s\n' $e | awk -F: '{print $1}')
            if test $n = $target
                set -l path (printf '%s\n' $e | awk -F: '{print $2}')
                # expand ~ or vars using eval echo
                set -l file (eval echo $path)
                if command -v nano >/dev/null
                    nano $file
                    return $status
                else if test -n "$EDITOR"
                    $EDITOR $file
                    return $status
                else
                    vi $file
                    return $status
                end
            end
        end
        echo "Unknown config: '$target'"
        echo ""
        _print_list
        return 2
    end

    # Interactive chooser
    if not command -v gum >/dev/null
        echo "Error: 'gum' not found in PATH. Install it or run: config <name>"
        return 1
    end

    # Build display lines "name — description"
    set -l display_lines
    for e in $entries
        set -l n (printf '%s\n' $e | awk -F: '{print $1}')
        set -l d (printf '%s\n' $e | awk -F: '{
            for(i=3;i<=NF;i++){ printf("%s%s",$i,(i<NF?":":"")) }
            printf "\n"
        }')
        set display_lines $display_lines "$n — $d"
    end

    set -l chosen (printf '%s\n' $display_lines | gum choose --header "Choose config to edit")
    if test -z "$chosen"
        # user cancelled
        return 1
    end

    # Extract the name from the chosen line ("name — description")
    set -l sel_name (printf '%s\n' "$chosen" | awk -F' — ' '{print $1}')

    # Find matching entry and open the file
    for e in $entries
        set -l n (printf '%s\n' $e | awk -F: '{print $1}')
        if test $n = $sel_name
            set -l path (printf '%s\n' $e | awk -F: '{print $2}')
            set -l file (eval echo $path)
            if command -v nano >/dev/null
                nano $file
                return $status
            else if test -n "$EDITOR"
                $EDITOR $file
                return $status
            else
                vi $file
                return $status
            end
        end
    end

    echo "Selected entry not found (this should not happen)."
    return 3
end
