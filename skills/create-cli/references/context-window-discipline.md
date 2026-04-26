# Context Window Discipline

Large API responses consume agent context window. When building CLIs that return potentially large outputs (lists, logs, API responses), help agents limit what they receive.

## Field Masks

Let agents request only the fields they need:

```bash
# Return all fields (default) - can be huge
mycli users list

# Return only specified fields
mycli users list --fields id,name,email

# Nested field selection
mycli users list --fields "id,profile.name,profile.avatar_url"
```

Implementation: Map `--fields` to the underlying API's field mask or projection parameter. If the API doesn't support field masks, filter the response before outputting.

## Output Limiting

Provide flags to limit output size:

```bash
# Limit number of results
mycli logs --lines 100
mycli list --limit 50

# Pagination
mycli list --page-size 20 --page 1
```

## Streaming with NDJSON

For large result sets, support NDJSON (Newline Delimited JSON) instead of buffered arrays:

```bash
# Buffered JSON array - must load entire response into memory/context
mycli list --json
# Output: [{"id": 1, ...}, {"id": 2, ...}, ...]

# NDJSON - stream-processable, one object per line
mycli list --output ndjson
# Output:
# {"id": 1, ...}
# {"id": 2, ...}
```

NDJSON advantages for agents:
- Process results incrementally without buffering
- Stop early once needed data is found
- Each line is valid JSON - can pipe to `jq` line by line

## Sensible Defaults

Don't overwhelm context by default:

```bash
# Bad: returns everything
mycli logs  # Returns 10,000 lines

# Good: sensible default with override
mycli logs  # Returns last 100 lines
mycli logs --all  # Explicit opt-in for full output
```

## When to Use

Apply context window discipline when:
- CLI wraps an API that returns lists or large objects
- Output could reasonably exceed 50-100 lines
- Agents will frequently use the command in automation
