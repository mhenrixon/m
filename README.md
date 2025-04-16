<img src="https://cdn.rawgit.com/oh-my-fish/oh-my-fish/e4f1c2e0219a17e2c748b824004c8d0b38055c16/docs/logo.svg" align="left" width="144px" height="144px"/>

#### m - Bookmark Manager
> A plugin for [Oh My Fish][omf-link].

[![Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg?style=flat-square)](LICENSE)
[![Fish Shell Version](https://img.shields.io/badge/fish-v3.0.0-007EC7.svg?style=flat-square)](https://fishshell.com)
[![Oh My Fish Framework](https://img.shields.io/badge/Oh%20My%20Fish-Framework-007EC7.svg?style=flat-square)](https://www.github.com/oh-my-fish/oh-my-fish)

<br/>

A powerful bookmark manager for the fish shell with sophisticated fuzzy matching. Easily save, organize, and navigate to your most frequently used directories.

## Features

- 📂 Save and manage directory bookmarks
- 🔍 Advanced fuzzy matching for quick navigation
- 🏠 Smart handling of $HOME paths for portability
- 🎯 Sophisticated scoring system for finding the best match
- 🚀 Fast and dependency-free implementation

## Install

```fish
$ omf install m
```

## Usage

```fish
# Show help information
$ m -h

# Save current directory as a bookmark
$ m -s project_name

# Jump to a saved bookmark
$ m project_name

# Jump with fuzzy matching (e.g., 'proj' will match 'project_name')
$ m proj

# List all bookmarks
$ m -l

# Search for bookmarks matching a pattern
$ m -f pattern

# Delete a bookmark
$ m -d bookmark_name

# Print the path of a bookmark
$ m -p bookmark_name

# Edit bookmarks file directly
$ m -e
```

## Fuzzy Matching

The fuzzy matching system uses a sophisticated scoring algorithm:

- Prefix matches are prioritized (e.g., "doc" matches "documents")
- Substring matches are scored next (e.g., "ument" matches "documents")
- Path matches are considered (matching text in the bookmark path)
- Character-by-character partial matches as a fallback

This allows you to quickly navigate to your bookmarks even if you can't remember the exact name.

## License

[Unlicense][unlicense] © [Mikael Henriksson][author] et [al][contributors]


[unlicense]:      https://unlicense.org
[author]:         https://github.com/mhenrixon
[contributors]:   https://github.com/mhenrixon/pkg-m/graphs/contributors
[omf-link]:       https://www.github.com/oh-my-fish/oh-my-fish

[license-badge]:  https://img.shields.io/badge/license-MIT-007EC7.svg?style=flat-square
