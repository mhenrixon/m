function tap-pretty
    while read -l line
        switch $line
            case "*ok*"
                set_color green
                echo "✓ $line"
            case "*not ok*"
                set_color red
                echo "✗ $line"
            case "# *"
                set_color cyan
                echo "$line"
            case "TAP*"
                set_color blue
                echo "$line"
            case "1..*"
                set_color yellow
                echo "$line"
            case "# pass*"
                set_color green
                echo "$line"
            case "# fail*"
                set_color red
                echo "$line"
            case "*"
                set_color normal
                echo "$line"
        end
        set_color normal
    end
end
