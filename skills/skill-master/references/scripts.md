# Scripts

Utility scripts that ship with a skill — when to add them and how to reference them.

Add a script when:
- Operations are deterministic (validation, formatting)
- The same code would be generated repeatedly
- Errors need explicit handling

**Use `/create-cli` to build utility CLIs.** When a skill needs a CLI script, use `/create-cli` to build it. This ensures the CLI is agent-friendly (non-interactive, parseable output, actionable errors).

**Make clear whether the agent should execute or read the script:**
- **Execute** (most common): "Run `analyze_form.py` to extract fields" — more reliable, saves tokens
- **Read as reference**: "See `analyze_form.py` for the extraction algorithm" — when the agent needs to understand the logic

**Don't assume packages are installed.** Be explicit about dependencies:
- Bad: "Use the pdf library to process the file."
- Good: "Install required package: `pip install pypdf`, then use `PdfReader` to open files."

**Give a default, not a menu.** Offering several equal options — "use pypdf, or pdfplumber, or PyMuPDF…" — is confusing. Pick one default and add an escape hatch for the edge case that needs another.
