# Save current directory as a bookmark
function __m_save_mark
  set -l name $argv[1]
  
  # Use current directory name if no name provided
  if test -z "$name"
    set name (basename (pwd))
    # Remove special characters
    set name (string replace -r '[^[:alnum:]_]' '' $name)
  end
  
  # Validate bookmark name
  if not string match -r '^[a-zA-Z0-9_]+$' $name > /dev/null
    echo "ERROR: Bookmark names may only contain alphanumeric characters and underscores."
    return 1
  end
  
  # Remove existing bookmark with the same name
  if __m_bookmark_exists $name
    __m_delete_mark $name > /dev/null
  end
  
  # Get current directory and replace $HOME with the variable for portability
  set -l current (pwd)
  set -l pwd (string replace $HOME '$HOME' $current)
  
  # Save current directory as a bookmark
  echo "$name $pwd" >> $MARKS_FILE
  echo "Bookmark '$name' saved: $current"
  
  # Update completions
  __m_update_completions
end
