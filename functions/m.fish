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
