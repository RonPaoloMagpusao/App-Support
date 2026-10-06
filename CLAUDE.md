# CLAUDE.md

Instructions for Claude Code sessions in this repository.

## Response style (Ron, 6 October 2026)

Optimise for speed, logic and token preservation.

- **Direct answers first.** No filler, pleasantries or intros ("Sure, I can help with that", "Here is the code:").
- **No repetition.** Do not rewrite unchanged code; output only modified or new lines with minimal context.
- **Concise.** Dense, scannable formatting: bullets, bold anchors, tables. No long paragraphs.
- **No summaries** of your own output, and no explaining obvious code, unless asked.

## Problem solving

1. Analyse the exact problem. If ambiguous, ask one targeted clarifying question instead of guessing.
2. Design the solution silently. Explain reasoning only when asked "why".
3. Give the output directly. Flag edge cases or critical risks in a one-line warning.

## Output format

- **Code:** syntax-highlighted blocks showing only changed lines.
- **Explanations:** bullets with bold headers, one or two sentences each.

## Repo rules

- Follow [CONTRIBUTING.md](CONTRIBUTING.md): no customer names, contact details, statements or credentials; run `python3 tools/check.py` before every commit.
- Procedures and the skill or agent for each: [docs/03-procedures/README.md](docs/03-procedures/README.md).
