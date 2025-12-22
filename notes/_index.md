# aRustyDev Notes

Welcome to the aggregated notes vault.

This vault pulls notes from multiple repositories:

- [[mcp/README|MCP Servers]]
- [[ai/README|AI Configuration]]

## How It Works

Notes are automatically aggregated from source repositories using sparse checkout. Each folder links to notes maintained in its respective repository.

See [sources.yml](https://github.com/aRustyDev/notes/blob/main/sources.yml) for the full list of sources.

## Local Development

```bash
# Pull all sources
just aggregate

# Open in Obsidian
just open

# Update existing sources
just update
```
