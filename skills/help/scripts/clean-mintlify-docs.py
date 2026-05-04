#!/usr/bin/env python3
"""Strip Mintlify-flavored JSX from a docs.md file, leaving plain markdown.

Reads from stdin, writes to stdout. Used by the help skill to clean up
docs fetched from https://code.claude.com/docs/<page>.md, which return
raw markdown but include Mintlify components (<Tip>, <Note>, <Warning>,
<Frame>, <Steps>, <Tabs>, <div>, <img>) and `theme={null}` modifiers.

Usage:
    curl -s https://code.claude.com/docs/en/hooks.md | python3 clean-mintlify-docs.py
"""
import re
import sys

src = sys.stdin.read()

# 1. Drop the leading "> ## Documentation Index" blockquote header
src = re.sub(r"\A(> .*\n)+\n", "", src)

# 2. Strip ` theme={null}` from fenced code-block opening lines (incl. indented)
src = re.sub(r"(```\S+)\s+theme=\{null\}", r"\1", src)

# 3. <Tip>/<Note>/<Warning>/<Info>/<Check> -> blockquotes with bold label
def admonition(match):
    kind = match.group(1)
    body = match.group(2).strip()
    lines = ["> **%s**" % kind] + ["> " + ln if ln else ">" for ln in body.splitlines()]
    return "\n".join(lines)

src = re.sub(
    r"<(Tip|Note|Warning|Info|Check)>\s*(.*?)\s*</\1>",
    admonition,
    src,
    flags=re.S,
)

# 4. <Frame>...</Frame> and <div ...>...</div> image wrappers -> drop wrapper, keep inner content
src = re.sub(r"<Frame>\s*", "", src)
src = re.sub(r"\s*</Frame>", "", src)
src = re.sub(r"^<div[^>]*>\s*\n", "", src, flags=re.M)
src = re.sub(r"^\s*</div>\s*\n", "", src, flags=re.M)

# 5. Convert <img ... src="URL" alt="ALT" .../> to ![ALT](URL)
def img_tag(match):
    attrs = match.group(0)
    src_m = re.search(r'src="([^"]+)"', attrs)
    alt_m = re.search(r'alt="([^"]+)"', attrs)
    url = src_m.group(1) if src_m else ""
    alt = alt_m.group(1) if alt_m else ""
    return f"![{alt}]({url})"

src = re.sub(r"<img\b[^>]*/?>", img_tag, src)

# 6. <Steps>...</Steps> -> numbered headings; <Step title="X">...</Step> -> #### Step N: X
def steps_block(match):
    body = match.group(1)
    n = [0]
    def step_repl(m):
        n[0] += 1
        title = m.group(1)
        inner = m.group(2).strip()
        return f"\n#### Step {n[0]}: {title}\n\n{inner}\n"
    body = re.sub(r'<Step\s+title="([^"]+)">\s*(.*?)\s*</Step>', step_repl, body, flags=re.S)
    return body

src = re.sub(r"<Steps>\s*(.*?)\s*</Steps>", steps_block, src, flags=re.S)

# 7. <Tabs>...</Tabs> -> drop wrapper; <Tab title="X">...</Tab> -> bold label
def tabs_block(match):
    body = match.group(1)
    body = re.sub(
        r'<Tab\s+title="([^"]+)">\s*(.*?)\s*</Tab>',
        lambda m: f"\n**{m.group(1)}**\n\n{m.group(2).strip()}\n",
        body,
        flags=re.S,
    )
    return body

src = re.sub(r"<Tabs>\s*(.*?)\s*</Tabs>", tabs_block, src, flags=re.S)

# 8. Collapse 3+ blank lines to 2
src = re.sub(r"\n{3,}", "\n\n", src)

sys.stdout.write(src)
