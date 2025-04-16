# Fuzzy jump to the best matching bookmark
function __m_fuzzy_jump
  set -l pattern $argv[1]
  if test -z "$pattern"
    echo "ERROR: Search pattern required"
    return 1
  end
  
  # Get matches sorted by score (each match is on a separate line)
  set -l all_matches
  
  # Read each line of output and build the array
  for match in (__m_find_mark $pattern)
    if test -n "$match"
      set -a all_matches $match
    end
  end
  
  # Check if we have any matches
  if not set -q all_matches[1]
    echo "ERROR: No bookmarks matching '$pattern' found"
    return 1
  end
  
  # Take the top match (highest score)
  set -l best_match $all_matches[1]
  
  # If we have multiple matches, show what we're doing
  if test (count $all_matches) -gt 1
    echo -e "\033[0;32mUsing best match: $best_match\033[0m"
  end
  
  # Verify the bookmark exists before jumping (extra safety check)
  if __m_bookmark_exists $best_match
    # Get the path
    set -l path (__m_get_bookmark_path $best_match)
    
    # Try to cd to the path
    if test -d "$path"
      cd "$path"
      echo "Jumped to '$best_match': $path"
      return 0
    else
      echo "ERROR: Directory '$path' for bookmark '$best_match' no longer exists"
      return 1
    end
  else
    echo "ERROR: Could not find bookmark '$best_match' (internal error)"
    return 1
  end
end
