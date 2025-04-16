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
