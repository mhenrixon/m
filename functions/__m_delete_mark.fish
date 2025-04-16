# Delete a bookmark
function __m_delete_mark
    set -l name $argv[1]
    if test -z "$name"
        echo "ERROR: Bookmark name required"
        return 1
    end

    if __m_bookmark_exists $name
        # Create a temporary file for the new content
        set -l temp_file (mktemp)
        grep -v "^$name " $MARKS_FILE >$temp_file
        mv $temp_file $MARKS_FILE
        echo "Bookmark '$name' deleted"

        # Update completions
        __m_update_completions
        return 0
    else
        echo "ERROR: Bookmark '$name' not found"
        return 1
    end
end
