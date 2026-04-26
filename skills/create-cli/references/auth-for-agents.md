# Auth for Agents

Agents cannot complete interactive authentication flows. Design auth patterns that work headlessly.

## The Problem

Traditional auth flows don't work for agents:
- OAuth browser redirects - agent can't click "Authorize"
- Interactive prompts - agent can't type passwords
- MFA/2FA - agent can't enter codes
- CAPTCHA - agent can't solve challenges

## Recommended Patterns

### Environment Variables for Tokens

The primary pattern for agent auth:

```bash
# Set token via environment
export MYCLI_TOKEN="eyJhbGc..."
mycli list

# Or API key
export MYCLI_API_KEY="sk-..."
mycli list
```

Naming conventions:
- `MYCLI_TOKEN` - bearer/access token
- `MYCLI_API_KEY` - API key
- `MYCLI_CREDENTIALS_FILE` - path to credentials JSON

### Credential Files

For complex credentials (service accounts, client secrets):

```bash
# Point to credentials file
export MYCLI_CREDENTIALS_FILE="/path/to/service-account.json"
mycli list

# Or via flag
mycli list --credentials-file /path/to/service-account.json
```

Never require the credentials content via flag (visible in process list).

### Service Accounts

Prefer service accounts over user credentials for automation:
- No user interaction required
- Scoped permissions
- Auditable
- Revocable without affecting user

### Token Refresh

If tokens expire, handle refresh automatically:

```bash
# Good: CLI handles refresh transparently
mycli list  # Refreshes token if needed, then executes

# Bad: CLI fails, agent must figure out refresh
mycli list
# Error: Token expired. Run 'mycli auth login' to refresh.
```

Store refresh tokens securely and refresh automatically when access token expires.

## What to Avoid

- **Flags for secrets**: `--token=xxx` is visible in `ps aux`
- **Interactive login as only path**: Always provide env var alternative
- **Short-lived tokens only**: Provide refresh mechanism or long-lived service account option

## Implementation Checklist

1. Support `MYCLI_TOKEN` or `MYCLI_API_KEY` environment variable
2. Support `MYCLI_CREDENTIALS_FILE` for complex credentials
3. Support `--credentials-file` flag as alternative
4. Auto-refresh tokens when possible
5. Document the headless auth path prominently
6. Fail with clear error if no credentials found:
   ```
   Error: No credentials found.
     Set MYCLI_TOKEN environment variable, or
     Set MYCLI_CREDENTIALS_FILE to a service account JSON path.
   ```
