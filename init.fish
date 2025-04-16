# m initialization hook
#
# You can use the following variables in this file:
# * $package       package name
# * $path          package path
# * $dependencies  package dependencies

# Set up marks file path
set -g MARKS_FILE $HOME/.marks

# Create bookmarks file if it doesn't exist
if ! test -f $MARKS_FILE
  touch $MARKS_FILE
end

# Initialize completions
__m_update_completions
