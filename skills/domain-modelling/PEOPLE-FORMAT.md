# PEOPLE.md Format

A roster of the specific people the project's work is for, with, or about — clients, stakeholders, internal owners. Non-code repos only. Always a single file at the repo root, even when the glossary is split across contexts: people cross contexts, and the roster is the most volatile domain doc — never shard or duplicate it.

## Structure

```md
# People

Names may arrive misspelled (voice dictation) — match people by sound and context, not exact spelling.

**Sarah Chen** — VP Sales, Acme Corp
- Relationship: client
- Owns/decides: sign-off on all pricing artifacts
- Cares about: cost reduction; how results read to her board
- Working with them: one page max, numbers up front
- Key relationships: reports to Tom Wu (CEO, Acme)

**Marcus Lee** — Engagement Lead
- Relationship: our side
- Owns/decides: scope changes and staffing
- Cares about: keeping the engagement renewable
```

## Entry shape

- **Name** — with role/title and org. Required.
- **Relationship** — this person's relation to us: client, our side, partner, regulator, investor… an open vocabulary — describe the relation, don't force a category. Required.
- **Owns/decides** — their authority relevant to the work: what they approve or control.
- **Cares about** — goals and priorities; shapes *what* you produce.
- **Working with them** — optional. Delivery notes; shapes *how* you present. Only when non-obvious — skip "likes clear writing".
- **Key relationships** — optional. Reports-to / works-with, only links that bear on the work.

A bare entry is fine: Name + Relationship + one other field.

## Rules

- **Match fuzzily before adding.** Names often arrive via voice dictation with variant spellings. Before creating an entry, check whether the person already exists under a similar-sounding name — a new spelling is usually an existing person, not a new one. Keep the roster's spelling unless the user corrects it.
- **Every line must change the work.** Before writing a fact, ask: would an artifact for or about this person differ because of it? If not, leave it out.
- **Professional working context only.** Record what a person stated or verifiably holds — never inferred sentiment, moods, or character notes.
- **Supersede, don't log.** When a fact changes, replace the old line. The roster is current state, not history. Remove people who leave the picture.
- **Group when clusters emerge** — by org or engagement — otherwise a flat list.
