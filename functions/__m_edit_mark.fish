# Edit the bookmarks file
function __m_edit_mark
  if test -n "$EDITOR"
    eval $EDITOR $MARKS_FILE
  else
    echo "No \$EDITOR variable set. Please set one first."
    return 1
  end
end
