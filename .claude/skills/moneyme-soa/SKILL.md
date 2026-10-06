---
name: moneyme-soa
description: Reformat a Horizon Statement of Account into MoneyMe's correct branded layout. Use whenever Ron supplies a Horizon SOA (HTML or PDF) plus a Customer Details PDF and wants it rebuilt, reformatted, fixed, or cleaned up: including when the SOA shows [Application].[EmailHeader] / [EmailSignature] / [EmailFooter] merge tokens or a masked xxxx customer name.
---

# MoneyMe SOA reformatter

Horizon generates Statements of Account with broken merge tokens where the
branding should be. This rebuilds the statement in the correct MoneyMe layout
**without altering a single figure**.

## The one rule

**Never change the data.** Reproduce every date, type, debit, credit and balance
exactly as supplied. Never recalculate the Balance column, Closing Balance or
Total interest, even when they look wrong (see *Expected oddities*).

The only thing taken from outside the SOA is the **customer name and address**,
read from the Customer Details PDF, because Horizon often masks it as `xxxx`.

## Run it

```bash
cd scripts

# 1. SOA HTML -> structured JSON  (prints a summary; writes parsed.json)
python3 parse_soa_html.py "<SOA>.html" parsed.json

# 2. Read the Customer Details PDF for the name + address, then assemble the
#    job JSON (see Schema below) as e.g. soa_<account>.json

# 3. Build. Prints any balance-chain break; writes .html and .pdf
python3 build_soa.py soa_<account>.json -o SOA_<account>_formatted
```

Deliver **the PDF only**: Ron does not want the HTML companion file.

## Assembling the job JSON

`parse_soa_html.py` gives you `reference_number`, `statement_date`, `account{}`
and `transactions[]`. Add the `customer` block from the Customer Details PDF:

```json
{
  "reference_number": "10001167510",
  "statement_date": "6 October 2026",
  "customer": {
    "first_name": "Jane",
    "full_name": "Miss Jane Citizen",
    "address_lines": ["1 23 Example Street", "Suburb", "Victoria 3000"]
  },
  "account": { "...": "straight from the parser" },
  "transactions": [ "...": "straight from the parser" ]
}
```

- `first_name` is the parser's `greeting_name`: whatever follows "Hi " in the
  SOA. It can be two words (first and middle name); keep it as-is.
- `full_name` / `address_lines` come from the Customer Details PDF.
- Everything in `account` comes from the **SOA**, never the Customer Details page.

## Verification: do this every time

`build_soa.py` runs a read-only chain check and prints any row where
`balance != prev + debit - credit` (or `!= prev` for a flagged row) by more than
1c. **A clean run means zero breaks.** Across 13 accounts and ~35,000 rows this
has never legitimately broken: so a break means a parse bug, not bad data.
Investigate it; do not "fix" the numbers.

Zero breaks also proves no row was dropped or duplicated at a page boundary.

Then sanity-check the output: page 1 (banner, summary box), the last page
(totals + sign-off + ABN block), and one page containing a red `X` row.

## Expected oddities: report, never correct

| What you'll see | What it is |
|---|---|
| Last row balance 1c below the stated Closing Balance | Daily Interest rounding: internal balance keeps full precision, displayed rows are rounded. Reproduce both as given. |
| Customer Details page disagrees on opening balance / period / total interest | Not an error. The SOA is full account history; the Customer Details page is the current quarter. Closing balance, outstanding charges and arrears do agree. **Use the SOA's figures.** |
| `Total interest for this period: $` blank on Customer Details | Known Horizon bug, ~1 account in 3, unrelated to account state. The SOA has the real figure. |
| Customer Details shows `01/01/0001`, $0.00 everywhere, "End of transaction history" | Specific to accounts closed by **Balance Migration**. The SOA itself is complete and correct. |
| Salutation is the literal word `Other` (e.g. "Other Jane Citizen", acct 10001037413) | Placeholder from the title dropdown. Drop it: never print it to a customer. |
| Address like `2 4 Example DR`, `1 18 Example Avenue`, `5 9-13 Example Road` | Unseparated unit number, almost certainly `2/4`, `1/18`, `5/9-13`. Reproduce verbatim and flag it to Ron. |
| An "Download our MONEYME App today" block with app-store badges | Not in the reference layout. Dropped. |

## Failed / pending transactions

Horizon prefixes the flag to the **amount cell**, not the Trans Type, and renders
that cell red: a failed Split Sched shows `X 200.87` in the Credit column. A
flagged row does **not** move the running balance. The parser picks this up from
the cell's own `color:red` style; `build_soa.py` re-renders it in `#FF0000`.

## If the SOA is a PDF instead of HTML

Horizon's printed SOAs are rasterised (Microsoft Print to PDF): no extractable
text. Ask Ron for the `.html` first; it parses from the DOM in seconds with zero
transcription risk, versus ~5 minutes of OCR and real risk on a 78-page PDF.

If a PDF is genuinely all there is: render pages with
`pdftoppm -r 300 -gray` for OCR plus `-r 150` colour for red-flag detection,
cut cells on the gridlines, stack each column into one tall strip with white
gutters so tesseract emits one line per cell, use per-column character
whitelists, and fall back to per-cell OCR for any column whose Trans Type wraps.
Then let the balance chain check prove the transcription.

## The logo

`scripts/logo_b64.txt` is bundled and used automatically. If it is ever lost or
corrupted, regenerate it from **any** Customer Details PDF: the same wordmark
appears top-left on every one:

```bash
python3 scripts/make_logo.py "<any customer details>.pdf"
```

Never try to restore it by retyping base64; it is ~45KB and silently truncates
into a PNG whose header parses but whose pixel data is a broken stream.

## Layout

Do not touch `scripts/template_head.html`. It is the layout, matched
page-for-page against the reference SOA: Letter, specific margins, 11pt Arial,
0.354in transaction row pitch, 10 rows on page 1 then 28 per page, closing block
forced onto its own page. `reference/soa-format-spec.md` documents every
measurement and why.

## Requirements

- Python 3 with `beautifulsoup4`, `lxml`, `pillow`, `numpy`
  (`pip install beautifulsoup4 lxml pillow numpy`)
- Chrome, Chromium or Edge for PDF rendering: found automatically, or set
  `MONEYME_CHROME` to the executable
- poppler-utils (`pdftoppm`): **optional**, only for regenerating the logo or
  rendering output pages to eyeball them
