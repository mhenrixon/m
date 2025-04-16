# Check if a bookmark exists
function __m_bookmark_exists
  set -l name $argv[1]
  if test -z "$name"
    return 1
  end
  
  grep -q "^$name " $MARKS_FILE
  return $status
end
