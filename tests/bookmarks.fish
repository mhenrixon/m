#!/usr/bin/env fish

set -l test_dir /tmp/fish_test_m_(random)
mkdir -p $test_dir

# Setup test environment
set -g MARKS_FILE $test_dir/.marks
touch $MARKS_FILE

# Include helper functions
source (dirname (status filename))/../functions/__m_bookmark_exists.fish
source (dirname (status filename))/../functions/__m_get_bookmark_path.fish
source (dirname (status filename))/../functions/__m_save_mark.fish
source (dirname (status filename))/../functions/__m_delete_mark.fish
source (dirname (status filename))/../functions/__m_update_completions.fish

@echo "Test Save Bookmark"
begin
    __m_save_mark test_mark
    @test "Bookmark should be saved" (__m_bookmark_exists "test_mark") $status -eq 0
end

@echo "Test Get Bookmark Path"
begin
    set -l path (__m_get_bookmark_path "test_mark")
    @test "Should return a path" (test -n "$path") $status -eq 0
end

@echo "Test Delete Bookmark"
begin
    __m_delete_mark test_mark
    @test "Bookmark should be deleted" (__m_bookmark_exists "test_mark") $status -ne 0
end

@echo "Test Find Bookmark"
begin
    __m_save_mark test_mark
    set -l matches (__m_find_mark "test_mark")
    @test "Should return a match" (test -n "$matches") $status -eq 0
end

@echo "Test Invalid Bookmark Names"
begin
    # Try to save with invalid characters
    set -l result (__m_save_mark "test-invalid!")
    @test "Should reject invalid bookmark names" (__m_bookmark_exists "test-invalid!") $status -ne 0
end

@echo "Test HOME Path Expansion"
begin
    # Save with $HOME in path
    set -l pwd (pwd)
    cd $HOME
    __m_save_mark home_test

    # Verify $HOME is properly expanded
    set -l path (__m_get_bookmark_path "home_test")
    @test "Should expand \$HOME in path" (string match -q "$HOME*" "$path") $status -eq 0

    __m_delete_mark home_test
    cd $pwd
end

@echo "Test Fuzzy Matching"
begin
    __m_save_mark test_project
    set -l matches (__m_find_mark "proj")
    @test "Fuzzy match should find the bookmark" (contains "test_project" $matches) $status -eq 0
    __m_delete_mark test_project
end

# Clean up test environment
rm -rf $test_dir
