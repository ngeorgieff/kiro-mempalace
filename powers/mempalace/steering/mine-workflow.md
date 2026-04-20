# Mine Workflow

How to mine projects and conversations into the MemPalace for persistent memory.

## What is Mining?

Mining indexes files from a project directory or conversation export into the palace. It auto-classifies content into wings (project name) and rooms (topic areas like "backend", "frontend", "config", etc.) using semantic analysis.

## Prerequisites

- `mempalace` installed (`pip install mempalace`)
- Palace initialized (`mempalace init`)

## Mining a Project

### Get Dynamic Instructions

The `mempalace` CLI provides up-to-date instructions for any operation:

```bash
mempalace instructions mine
```

Follow the returned instructions step by step.

### Basic Usage

```bash
# Mine the current directory
mempalace mine .

# Mine a specific project
mempalace mine /path/to/project

# Mine with a specific wing name
mempalace mine . --wing my-project
```

### What Gets Mined

- Source code files (with language detection)
- README and documentation files
- Configuration files (package.json, tsconfig, etc.)
- Conversation exports (if supported format)

### What Gets Skipped

- Binary files
- `node_modules`, `.git`, `__pycache__`, etc.
- Files matching `.gitignore` patterns

## Mining Conversations

If you have exported conversation logs (JSON, markdown):

```bash
mempalace mine /path/to/conversations --type conversation
```

## Auto-Mining with MEMPAL_DIR

Set the `MEMPAL_DIR` environment variable to automatically mine a directory during each auto-save trigger:

```bash
export MEMPAL_DIR=/path/to/project
```

This is useful for keeping the palace up-to-date with a frequently changing project.

## Post-Mine Verification

After mining, verify the results:

1. `mempalace_list_wings` — confirm the wing was created
2. `mempalace_list_rooms(wing="your-project")` — check room classification
3. `mempalace_search(query="test keyword", wing="your-project")` — verify search works

## Best Practices

- Mine at project milestones (after major features, releases)
- Use consistent wing names matching your repo/project name
- Re-mine after significant refactors to update the palace
- Don't mine too frequently — focus on meaningful snapshots
- Review the auto-classified rooms and rename if needed via drawer operations
