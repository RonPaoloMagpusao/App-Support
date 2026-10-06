# MoneyMe SOA reformatter: Claude Code skill

Rebuilds a Horizon Statement of Account in MoneyMe's correct branded layout,
with every figure reproduced exactly as supplied.

## Install

Unzip so the folder sits in one of these places:

| Path | Scope |
|---|---|
| `~/.claude/skills/moneyme-soa/` | you, in every project |
| `<your repo>/.claude/skills/moneyme-soa/` | shared with the team via git |

On Windows `~` is `C:\Users\<you>`.

```bash
mkdir -p ~/.claude/skills
unzip moneyme-soa-skill.zip -d ~/.claude/skills/
pip install beautifulsoup4 lxml pillow numpy
```

Start `claude`, then `/doctor` or ask "what skills do you have?" to confirm
`moneyme-soa` is listed.

## Use

Drop the two files in your working folder and say:

> Reformat this SOA: 10001167510 SOA.html and 10001167510 customer details.pdf

Claude Code picks up the skill from the description and runs the pipeline.

## What's inside

```
moneyme-soa/
  SKILL.md                      what Claude Code reads
  scripts/
    parse_soa_html.py           SOA HTML  -> JSON
    build_soa.py                JSON      -> HTML + PDF, with the chain check
    make_logo.py                regenerate the logo from a Customer Details PDF
    template_head.html          the layout (do not edit)
    logo_b64.txt                MONEYME wordmark, embedded at build time
    moneyme_logo.png            same, as a PNG
  reference/
    soa-format-spec.md          every measurement, every Horizon glitch, run log
```

## Notes

- PDF rendering uses Chrome/Chromium/Edge headless. Set `MONEYME_CHROME` if it
  isn't found automatically.
- `build_soa.py` validates the balance chain on every run and prints any row
  that doesn't reconcile. It never changes a value.
