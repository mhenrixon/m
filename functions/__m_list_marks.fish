# List all bookmarks
function __m_list_marks
    if test -s $MARKS_FILE
        printf "\033[0;33m%-20s\033[0m %s\n" BOOKMARK LOCATION
        printf "%-40s\n" ----------------------------------------
        while read -l name path
            printf "\033[0;33m%-20s\033[0m %s\n" $name $path
        end <$MARKS_FILE
    else
        echo "No bookmarks found. Use 'm -s <name>' to create one."
    end
end
