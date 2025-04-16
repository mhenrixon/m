function test-bookmarks
    echo "Running bookmark manager tests..."
    fishtape (dirname (status dirname))/tests/*.fish | tap-pretty
end
