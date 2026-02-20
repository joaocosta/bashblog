# BashBlog Test Suite

This directory contains the test suite for `bb.sh`, built using [BATS (Bash Automated Testing System)](https://github.com/bats-core/bats-core).

## Setup

The easiest way to set up the test environment is to run the main project setup script from the root directory:

```bash
./setup.sh
```

Alternatively, you can manually initialize the `bats-core` submodule:

```bash
git submodule init
git submodule update
```

## Running Tests

Once the submodule is initialized, you can run the full test suite:

```bash
./tests/bats-core/bin/bats tests/bb.bats
```

## Maintenance

### Updating `bats-core`

To update the `bats-core` submodule to the latest commit:

```bash
cd tests/bats-core
git checkout master
git pull origin master
cd ../..
git add tests/bats-core
git commit -m "Update bats-core submodule"
```

### Adding New Tests

1.  Edit `tests/bb.bats`.
2.  Add a new `@test` block.
3.  Use `run ./bb.sh <command>` to execute the script.
4.  Assert success with `[ "$status" -eq 0 ]`.
5.  Check output with `[[ "$output" =~ "Expected String" ]]`.

### Mocking the Editor

Since `bb.sh` uses `$EDITOR` to open posts, we mock this behavior in tests to prevent interactive editors (like vim or nano) from blocking execution.

*   **`tests/mock_editor.sh`**: A simple script that appends content from the `MOCK_EDITOR_CONTENT` environment variable to the file being edited.
*   In `bb.bats`, we set `export EDITOR="$BATS_TEST_DIRNAME/mock_editor.sh"` in the `setup()` function.
*   To simulate user input during a test:
    ```bash
    export MOCK_EDITOR_CONTENT="<p>My new content</p>"
    run bash -c "echo 'p' | ./bb.sh post -html"
    ```
