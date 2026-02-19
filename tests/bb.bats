#!/usr/bin/env bash

# Setup function: runs before each test
setup() {
    # Create a temporary directory for the test environment
    TEST_DIR=$(mktemp -d)
    
    # Path to the script under test
    SCRIPT_PATH="$BATS_TEST_DIRNAME/../bb.sh"
    MARKDOWN_PATH="$BATS_TEST_DIRNAME/../Markdown.pl"
    
    # Copy necessary files to the test directory
    cp "$SCRIPT_PATH" "$TEST_DIR/bb.sh"
    if [ -f "$MARKDOWN_PATH" ]; then
        cp "$MARKDOWN_PATH" "$TEST_DIR/Markdown.pl"
        chmod +x "$TEST_DIR/Markdown.pl"
    fi
    
    # Switch to the test directory
    cd "$TEST_DIR" || exit 1
    
    # Make bb.sh executable
    chmod +x bb.sh
    
    # Mock EDITOR to avoid opening interactive editors
    export MOCK_EDITOR="$BATS_TEST_DIRNAME/mock_editor.sh"
    chmod +x "$MOCK_EDITOR"
    export EDITOR="$MOCK_EDITOR"
}

# Teardown function: runs after each test
teardown() {
    # Remove the temporary directory
    if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
    fi
}

@test "Usage info is displayed when no arguments are provided" {
    run ./bb.sh
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
}

@test "Create a new post (HTML mode)" {
    # Set up mock editor content
    export MOCK_EDITOR_CONTENT="<p>This is a test post content.</p>"
    
    # Simulate user input 'p' (post)
    run bash -c "echo 'p' | ./bb.sh post -html"
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Posted" ]]
    
    # Default title is "Title on this line" -> filename "title-on-this-line.html"
    [ -f "title-on-this-line.html" ]
    
    # Verify content
    grep -q "This is a test post content" "title-on-this-line.html"
}

@test "Create a new post (Markdown mode)" {
    if [ ! -f "Markdown.pl" ]; then
        skip "Markdown.pl not found"
    fi

    # Set up mock editor content (Markdown)
    export MOCK_EDITOR_CONTENT="**Bold Text**"
    
    # Simulate user input 'p' (post)
    run bash -c "echo 'p' | ./bb.sh post"
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Posted" ]]
    
    # Check if file exists
    [ -f "title-on-this-line.html" ]
    
    # Verify Markdown conversion (Bold Text -> <strong> or <b>)
    if grep -q "<strong>Bold Text</strong>" "title-on-this-line.html"; then
        true
    else
        grep -q "<b>Bold Text</b>" "title-on-this-line.html"
    fi
}

@test "Edit an existing post" {
    # Create a post first
    echo 'p' | ./bb.sh post -html
    file="title-on-this-line.html"
    [ -f "$file" ]
    
    # Now edit it. bb.sh edit opens editor.
    # We want to change the content.
    # Mock editor script appends content.
    export MOCK_EDITOR_CONTENT="<p>Edited content</p>"
    
    run ./bb.sh edit "$file"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Posted $file" ]]
    
    # Check content
    grep -q "Edited content" "$file"
}

@test "Rebuild blog" {
    # Create a post
    echo 'p' | ./bb.sh post -html
    
    # Run rebuild
    run ./bb.sh rebuild
    [ "$status" -eq 0 ]
    
    # Check output messages
    [[ "$output" =~ "Rebuilding all entries" ]]
    [[ "$output" =~ "Rebuilding tag pages" ]]
    [[ "$output" =~ "Rebuilding the index" ]]
    
    # Verify index exists
    [ -f "index.html" ]
    
    # Verify RSS exists
    [ -f "feed.rss" ]
}

@test "List posts" {
    # Create custom editor to set title
    cat <<EOF > editor_title.sh
#!/bin/bash
# Replaces title
sed -i "s/Title on this line/\$NEW_TITLE/" "\$1"
EOF
    chmod +x editor_title.sh
    export EDITOR="./editor_title.sh"
    
    # Post 1
    export NEW_TITLE="Post One"
    echo 'p' | ./bb.sh post -html
    
    # Post 2
    export NEW_TITLE="Post Two"
    echo 'p' | ./bb.sh post -html
    
    run ./bb.sh list
    [ "$status" -eq 0 ]
    
    [[ "$output" =~ "Post One" ]]
    [[ "$output" =~ "Post Two" ]]
}

@test "List tags" {
    # Create custom editor to set tags
    cat <<EOF > editor_tags.sh
#!/bin/bash
# Replaces tags
sed -i "s/tags-are-optional/mytag1, mytag2/" "\$1"
EOF
    chmod +x editor_tags.sh
    export EDITOR="./editor_tags.sh"
    
    echo 'p' | ./bb.sh post -html
    
    run ./bb.sh tags
    [ "$status" -eq 0 ]
    
    [[ "$output" =~ "mytag1" ]]
    [[ "$output" =~ "mytag2" ]]
}

@test "Delete a post" {
    # Create a post
    echo 'p' | ./bb.sh post -html
    file="title-on-this-line.html"
    
    [ -f "$file" ]
    
    run ./bb.sh delete "$file"
    [ "$status" -eq 0 ]
    
    # File should be gone
    [ ! -f "$file" ]
    
    # Rebuild should have run (index updated)
    # Check if output mentions rebuilding
    [[ "$output" =~ "Rebuilding tag pages" ]]
}

@test "Reset blog" {
    # Create some content
    echo 'p' | ./bb.sh post -html
    [ -f "title-on-this-line.html" ]
    [ -f "index.html" ]
    
    # Run reset with confirmation
    run bash -c "echo 'Yes, I am!' | ./bb.sh reset"
    [ "$status" -eq 0 ]
    
    # Check clean up
    [[ "$output" =~ "Deleted all posts" ]]
    [ ! -f "title-on-this-line.html" ]
    [ ! -f "index.html" ]
    [ ! -f "feed.rss" ]
}

@test "HTML generation structure" {
    # Create post
    echo 'p' | ./bb.sh post -html
    file="title-on-this-line.html"
    
    content=$(cat "$file")
    
    # Check for basic HTML structure
    [[ "$content" =~ "<html>" || "$content" =~ "<html" ]]
    [[ "$content" =~ "<body>" ]]
    [[ "$content" =~ "header" || "$content" =~ "Header" ]] # Case varies depending on template
    [[ "$content" =~ "footer" || "$content" =~ "Footer" || "$content" =~ "Generated with" ]]
}

@test "Date parsing and format" {
    # Create post
    echo 'p' | ./bb.sh post -html
    file="title-on-this-line.html"
    
    # Check that the timestamp is present and correctly formatted
    # Look for the internal comment timestamp
    run grep "bashblog_timestamp" "$file"
    [ "$status" -eq 0 ]
    # Format: YYYYMMDDHHMM.SS (12+ digits)
    [[ "$output" =~ [0-9]{12} ]]
    
    # Check visible date in subtitle
    content=$(cat "$file")
    # We don't know the exact date, but we can look for the div class="subtitle"
    [[ "$content" =~ "<div class=\"subtitle\">" ]]
}

@test "Save as draft" {
    # Input 'd' for draft
    run bash -c "echo 'd' | ./bb.sh post -html"
    [ "$status" -eq 0 ]
    
    [[ "$output" =~ "Saved your draft as" ]]
    
    # Check drafts folder
    [ -d "drafts" ]
    count=$(ls drafts/*.html | wc -l)
    [ "$count" -ge 1 ]
}

@test "Configuration override (.config)" {
    # Create .config file
    echo 'global_title="TEST_BLOG_TITLE"' > .config
    
    # Create post
    echo 'p' | ./bb.sh post -html
    file="title-on-this-line.html"
    
    content=$(cat "$file")
    [[ "$content" =~ "TEST_BLOG_TITLE" ]]
}
