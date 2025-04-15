#!/usr/bin/env fish

# Set up marks file
set -g MARKS_FILE $HOME/.marks

if ! test -f $MARKS_FILE
  touch $MARKS_FILE
end

function m -d "Bookmark manager with sophisticated fuzzy search"
  if count $argv >/dev/null
    switch $argv[1]
      case "-h" "--help"
        __m_print_usage
      case "-e" "--edit"
        __m_edit_mark
      case "-l" "--list"
        __m_list_marks
      case "-p" "--print"
        if test -n "$argv[2]"
          __m_print_mark $argv[2]
        else
          echo "ERROR: Bookmark name required for -p/--print"
        end
      case "-s" "--save"
        __m_save_mark $argv[2]
      case "-d" "--delete"
        if test -n "$argv[2]"
          __m_delete_mark $argv[2]
        else
          echo "ERROR: Bookmark name required for -d/--delete"
        end  
      case '-f' '--find'
        if test -n "$argv[2]"
          # Search and display results but don't jump to any bookmark
          set -l all_matches
          
          # Read each line of output and build the array
          for match in (__m_find_mark $argv[2])
            if test -n "$match"
              set -a all_matches $match
            end
          end
          
          if not set -q all_matches[1]
            echo "No bookmarks matching '$argv[2]' found"
          else
            echo "Found "(count $all_matches)" matches for '$argv[2]':"
            for match in $all_matches
              set -l path (__m_get_bookmark_path $match)
              printf "\033[0;33m%-20s\033[0m %s\n" $match $path
            end
          end
        else
          echo "ERROR: Search pattern required for -f/--find"
        end
      case '*'
        # Try exact match first, then fall back to fuzzy
        if __m_bookmark_exists $argv[1]
          __m_use_mark $argv[1]
        else
          __m_fuzzy_jump $argv[1]
        end
    end
  else
    __m_list_marks
  end
end

# Print usage information
function __m_print_usage
  echo 'Usage:
  m [OPTION] [BOOKMARK]

General Options:
  -h, --help                   - Show this usage information
  -l, --list                   - List all bookmarks
  -e, --edit                   - Edit bookmarks file with $EDITOR
  -s, --save   <mark_name>     - Save current directory as "mark_name"
  -p, --print  <mark_name>     - Print directory for "mark_name"
  -d, --delete <mark_name>     - Delete "mark_name" bookmark
  -f, --find   <pattern>       - Find bookmarks matching pattern
  <mark_name or pattern>       - Go to bookmark (with fuzzy matching)
  
Fuzzy Matching:
  If <mark_name> is not an exact match, the tool will try to find the
  best matching bookmark using a sophisticated scoring system:
  - Prefix matches are prioritized (e.g., "doc" matches "documents")
  - Substring matches are next (e.g., "ument" matches "documents")
  - Path matches are considered (matching in the bookmark path)
  - Character-by-character partial matches as fallback'
end

# Edit the bookmarks file
function __m_edit_mark
  if test -n "$EDITOR"
    eval $EDITOR $MARKS_FILE
  else
    echo "No \$EDITOR variable set. Please set one first."
    return 1
  end
end

# List all bookmarks
function __m_list_marks
  if test -s $MARKS_FILE
    printf "\033[0;33m%-20s\033[0m %s\n" "BOOKMARK" "LOCATION"
    printf "%-40s\n" "----------------------------------------"
    while read -l name path
      printf "\033[0;33m%-20s\033[0m %s\n" $name $path
    end < $MARKS_FILE
  else
    echo "No bookmarks found. Use 'm -s <name>' to create one."
  end
end

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



# Check if a bookmark exists
function __m_bookmark_exists
  set -l name $argv[1]
  if test -z "$name"
    return 1
  end
  
  grep -q "^$name " $MARKS_FILE
  return $status
end

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

# Print the path of a bookmark
function __m_print_mark
  set -l name $argv[1]
  if test -z "$name"
    echo "ERROR: Bookmark name required"
    return 1
  end
  
  if __m_bookmark_exists $name
    __m_get_bookmark_path $name
    return 0
  else
    echo "ERROR: Bookmark '$name' not found"
    return 1
  end
end

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
    grep -v "^$name " $MARKS_FILE > $temp_file
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

# Initialize completions
__m_update_completions
