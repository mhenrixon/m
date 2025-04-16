# Use a bookmark (cd to the directory)
function __m_use_mark
    set -l name $argv[1]
    if test -z "$name"
        echo "ERROR: Bookmark name required"
        return 1
    end

    # Try exact match first
    if __m_bookmark_exists $name
        set -l path (__m_get_bookmark_path $name)

        # Try to cd to the path
        if test -d "$path"
            cd "$path"
            echo "Jumped to '$name': $path"
            return 0
        else
            echo "ERROR: Directory '$path' for bookmark '$name' no longer exists"
            return 1
        end
    else
        # For direct use_mark calls, we don't do fuzzy matching
        # The fuzzy matching is handled by __m_fuzzy_jump
        echo "ERROR: No bookmark named '$name' found"
        return 1
    end
end
