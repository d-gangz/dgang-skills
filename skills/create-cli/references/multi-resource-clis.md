# Multi-Resource CLIs

For CLIs that manage multiple resource types (like Docker managing containers, images, volumes; or kubectl managing pods, services, deployments), use noun-verb ordering.

## The Pattern

Resource first, then action:

```bash
mycli user list
mycli user create
mycli project list      # Same verb as user list
mycli project create    # Same verb as user create
```

This is the dominant pattern in complex CLIs:
- `docker container list`, `docker image list`
- `kubectl get pods`, `kubectl get services`
- `gh repo clone`, `gh issue list`

## Why Noun-Verb?

Agents guess by analogy. If `mycli user list` exists, they'll try `mycli project list`. Noun-verb makes this predictable:

1. **Discoverable** - `mycli user --help` shows all user operations
2. **Consistent** - Same verbs work across all resource types
3. **Extensible** - Adding a new resource type follows the same pattern

## Standard Verbs

Reuse these across all resource types:

| Verb | Purpose |
|------|---------|
| `list` | List all resources |
| `get` | Get one resource by ID |
| `create` | Create a new resource |
| `update` | Modify an existing resource |
| `delete` | Remove a resource |

If `user` supports `list`, `create`, `delete`, then `project` should too.

## When to Use This

Use noun-verb when your CLI:
- Manages 3+ distinct resource types
- Resources share common operations (CRUD)
- Users need to discover what operations exist per resource

For simpler CLIs with just a few verb commands (`mycli deploy`, `mycli build`), this pattern is overkill.
