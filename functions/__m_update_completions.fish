# Update autocompletions
function __m_update_completions
  set -l bookmarks (cut -d ' ' -f 1 $MARKS_FILE)
  
  complete -e -c m
  complete -c m -f -a "$bookmarks" -d "Bookmarked location"
  complete -c m -s h -l help -d "Show usage help"
  complete -c m -s l -l list -d "List all bookmarks"
  complete -c m -s e -l edit -d "Edit bookmarks"
  complete -c m -s s -l save -d "Save current directory" -x
  complete -c m -s p -l print -d "Print bookmark path" -r -a "$bookmarks"
  complete -c m -s d -l delete -d "Delete bookmark" -r -a "$bookmarks"
  complete -c m -s f -l find -d "Find bookmark" -x
end
