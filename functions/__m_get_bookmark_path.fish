# Get the path for a bookmark
function __m_get_bookmark_path
  set -l name $argv[1]
  if test -z "$name"
    return 1
  end
  
  set -l path (grep "^$name " $MARKS_FILE | cut -d ' ' -f 2-)
  
  # Expand $HOME in the path if present
  if string match -q '*$HOME*' $path
    set path (string replace '$HOME' $HOME $path)
  end
  
  # Remove quotes if present
  set path (string trim -c '\"' $path)
  
  echo $path
end
