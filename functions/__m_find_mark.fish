# Fuzzy find bookmarks matching a pattern
function __m_find_mark
  set -l pattern $argv[1]
  if test -z "$pattern"
    echo "ERROR: Search pattern required"
    return 1
  end
  
  # Score-based fuzzy matching implementation
  set -l matches
  set -l scores
  
  # Read all bookmarks
  while read -l line
    # Skip empty lines
    if test -z "$line"
      continue
    end
    
    # Extract key and path
    set -l parts (string split -m 1 " " $line)
    if test (count $parts) -lt 2
      continue
    end
    
    set -l key $parts[1]
    set -l path $parts[2]
    set -l score 0
    
    # Score is higher for direct prefix match
    if string match -i "$pattern*" "$key" >/dev/null
      set score 100
    # Score is medium for substring match in key
    else if string match -i "*$pattern*" "$key" >/dev/null
      set score 50
    # Score is low for substring match in path
    else if string match -i "*$pattern*" "$path" >/dev/null
      set score 25
    # Score is very low for separated character match
    else
      # Try character-by-character matching
      set -l chars (string split '' $pattern)
      set -l pattern_regex ""
      for char in $chars
        set pattern_regex "$pattern_regex.*$char"
      end
      
      if string match -ri "$pattern_regex" "$key" >/dev/null
        set score 10
      else if string match -ri "$pattern_regex" "$path" >/dev/null
        set score 5
      end
    end
    
    # If there's a match, add it to results
    if test $score -gt 0
      set -a matches $key
      set -a scores $score
    end
  end < $MARKS_FILE
  
  # Sort matches by score (highest first)
  set -l sorted_matches
  set -l match_count (count $matches)
  
  # Only process if we have matches
  if test $match_count -gt 0
    # First, get all high-score (100) matches
    for i in (seq $match_count)
      if test $scores[$i] -eq 100
        set -a sorted_matches $matches[$i]
      end
    end
    
    # Then medium score (50) matches
    for i in (seq $match_count)
      if test $scores[$i] -eq 50
        set -a sorted_matches $matches[$i]
      end
    end
    
    # Then low score (25) matches
    for i in (seq $match_count)
      if test $scores[$i] -eq 25
        set -a sorted_matches $matches[$i]
      end
    end
    
    # Then very low score (10) matches
    for i in (seq $match_count)
      if test $scores[$i] -eq 10
        set -a sorted_matches $matches[$i]
      end
    end
    
    # Then lowest score (5) matches
    for i in (seq $match_count)
      if test $scores[$i] -eq 5
        set -a sorted_matches $matches[$i]
      end
    end
  end
  
  # Return each match on a separate line to avoid spaces causing issues
  for match in $sorted_matches
    echo $match
  end
end
