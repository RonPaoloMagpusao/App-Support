# MoneyMe SOA (Statement of Account): layout spec

Reverse-engineered from a Horizon "Loan Document Preview" SOA printed via
Microsoft Print to PDF. Verified page-for-page against the reference:
pagination matches exactly (11/28/28/28/28/2 rows + closing page), and text
overlays with zero visible offset.

## Page setup
- Letter (612 x 792 pt / 8.5 x 11 in)
- `@page` margins: **top 0.399in, right 0.378in, bottom 0.47in, left 0.473in**
- Page 1 only: `body { padding-top: 0.071in }`: the banner sits lower than
  continuation-page content
- Font: Arial / Helvetica throughout. Body **11pt**, line-height 1.5

## Page 1 structure (top to bottom)
| Element | Spec |
|---|---|
| Green banner | `#BAEA02`, full content width, height 1.247in. MONEYME wordmark 1.435 x 0.277in, inset 0.845in left / 0.505in top |
| Reference strip | right-aligned, 11px, `#767676`, padding-right 11px, margin-top 13px |
| `Hi <FirstName>,` | margin-left 0.100in, margin-top 38px |
| `Reference number <ref>` | margin-left 0.100in, margin-top 15px |
| **Statement block** | container: margin-left 0.796in, margin-right 0.790in |
| `YOUR ACCOUNT STATEMENT` | 13.75pt bold, margin-top 33px |
| Meta row | 2-col 50/50 table, padding-left 4px, margin-top 20px. Left = `Reference number: <ref>`, right = statement date |
| Account summary box | 1px `#ccc`, 2 cells 50/50, padding 9px, margin-top 20px. Left cell **vertically centred** = name + address. Right cell **top-aligned** = Account Summary / Opening / Closing / Statement Period / Contract Type |
| Legend | bold, two lines, margin-top 17px |
| Transaction table | margin-top 19px, 11px font, line-height 1.15, 1px solid black collapsed borders, cell padding `10.185px 6px` → row pitch 0.354in |

Column widths: Date 15% · Trans Type 35% · Debit 15% · Credit 15% · Balance 20%

The header row is a normal `<tr>` inside `<tbody>`: it must **not** repeat on
continuation pages (do not use `<thead>`). Pages hold 10 rows (page 1) then 28.

## Closing page
`page-break-before: always`: the closing block always starts on its own page.

| Element | Spec |
|---|---|
| Totals | margin-left 0.302in, margin-top 17px, line-height 0.25in, bold labels |
| Sign-off | margin-left 0.119in, margin-top 64px; phone in `#ADCB07` bold |
| Cheers | margin-top 20px, `Cheers,` / `Team MONEYME` (bold) |
| Contact footer | centred, 6.9pt, line-height 0.1535in, `#3f3f3f`, margin-top 43px. Bold `T`/`E` labels. Closing page only: not a running footer |

## Brand colours
Banner green `#BAEA02` · phone green `#ADCB07` · wordmark `#1C3132` ·
summary-box border `#CCCCCC` · reference strip grey `#767676` · failed-txn red `#FF0000`

## Rendering
`build_soa.py` (JSON in → HTML + PDF out) via headless Chromium
`--print-to-pdf --no-pdf-header-footer`.
Manual print settings that reproduce it: Letter · Margins **Default** ·
Scale **100%** · Headers and footers **OFF** · Background graphics **ON**.

## Failed / pending markers
Horizon prefixes the flag to the **amount cell**, not the Trans Type, and
renders the whole cell in red: e.g. a failed Split Sched shows `X 200.87` in
the Credit column. A flagged row does **not** move the running balance
(balance = previous balance).

## Delivery (Ron, 5 Oct 2026)
Send the **PDF only**: no HTML companion file.

## Agreed workflow (Ron)
- **Balances: reproduce exactly as supplied.** Never recalculate the Balance
  column, Closing Balance or Total interest.
- `build_soa.py` runs a read-only chain check and prints any row where
  `balance != prev + debit - credit` (or `!= prev` when flagged) by more than
  1c, purely to catch a parse/transcription slip. 1c drift on `Daily Interest`
  is normal in Horizon and is ignored.
- Take **only name and address** from the Customer Details page; every figure
  comes from the SOA itself.

## Preferred input: the Horizon SOA **HTML** (not the printed PDF)
`parse_soa_html.py` reads values straight from the DOM: no OCR, no
transcription risk. Rows come from the `Date`/`Trans Type` table; the
failed/pending flag from the cell's own `color:red` style (or an `X `/`P `
prefix); header/summary/totals from the document text.

Seconds, versus ~5 minutes of OCR for the one 78-page rasterised PDF.
Ask for the `.html` first; fall back to OCR only when a PDF is all there is.

### OCR fallback (rasterised SOAs only)
1. `pdftoppm -r 300 -gray` for OCR, `-r 150` colour for red-flag detection.
2. Find gridlines; keep every row band (row heights vary: Trans Type wraps).
3. Stack each column's cells into one tall strip with white gutters so
   tesseract emits one line per cell; per-column character whitelists.
4. A wrapped cell breaks strip alignment → that column falls back to per-cell
   OCR with lines joined.
5. Flags read from `#FF0000` pixels per cell.
6. Validate with the balance chain: zero breaks also proves no row was dropped
   or duplicated at a page boundary.

## Known Horizon glitches
- `[Application].[EmailHeader]` / `[EmailSignature]` / `[EmailFooter]` -
  unresolved merge tokens where the banner, sign-off and ABN block should be.
  All three now appear on every SOA seen.
- Customer name/address masked as `xxxx` (acct 10001459594).
- A "Download our MONEYME App today" block with app-store badges appears in the
  generated SOA but not in the reference; it is dropped.
- The Customer Details page and the SOA legitimately disagree on opening
  balance / statement period / total interest: the SOA is full account history,
  the Customer Details page is the current statement period. Closing balance,
  outstanding charges and arrears match across both.
- Salutation can be the literal placeholder `Other`: acct 10001037413 came
  through as "Other <FirstName> <LastName>". Drop it; never print it to a customer.
- **The statement date is not always today.** `parse_soa_html.py` reads it out
  of the SOA rather than having it hardcoded.
- Last row balance can sit 1c below the stated Closing Balance. Seen twice:
  acct 10001404007 ($8,019.74 vs $8,019.75) and acct 10000630336 ($2,029.35 vs
  $2,029.36). Daily Interest rounding drift: internal balance carries full
  precision, displayed row balances are rounded. Reproduce both as given.
- Address lines can carry an unseparated unit number: "2 4 <Street> DR"
  (acct 10001167979), "1 18 <Street> Avenue" (acct 10000630336). Almost certainly
  "2/4" and "1/18" in the source. Reproduce verbatim; flag it to Ron.

## Pattern: degraded Customer Details == account closed by Balance Migration
| Account | Last transaction | Customer Details page |
|---|---|---|
| 10001459594 | Daily Interest (open) | healthy |
| 10000627167 | Direct Credit (open) | healthy |
| 10001167979 | **Balance Migration → $0.00** | **degraded** |
| 10001037413 | Accounting Fee (open) | healthy |
| 10001133359 | Accounting Fee (open) | healthy |
| 10000970018 | **Balance Migration → $0.00** | **degraded** |
| 10001404007 | Daily Interest (open) | healthy |
| 10000630336 | Daily Interest (open) | healthy |
| 10001081999 | Daily Interest (open) | healthy |
| 10001197634 | Daily Interest (open) | healthy |
| 10000899629 | Daily Interest (open) | healthy |
| 10001093600 | Daily Interest (open) | healthy |
| 10001167510 | **Direct Credit payout → $0.00** | partial (total interest blank only) |

"Degraded" means the same symptoms every time: opening $0.00, closing $0.00,
statement period `01/01/0001 - <today>`, a blank `$` for total interest, and
"End of transaction history" with no rows: while the SOA itself is complete
and correct. Only outstanding charges and current arrears survive.

Reads like the Customer Details query can't resolve a statement period once an
account has been migrated/closed out, and the null start date (`01/01/0001` =
`DateTime.MinValue` / SQL `datetime` floor) then yields an empty transaction
window. Worth raising as an MHD Problem: 2 for 2 on Balance Migration closures.

**Refinement (acct 10001167510, 6 Oct 2026).** A closed account does *not*
automatically get the full failure. This one was closed by a **Direct Credit
payout** of $13,027.41 rather than a Balance Migration, and its page kept a
valid statement period, a real opening balance and the correct $0.00 closing -
only Total interest came through blank. So the `01/01/0001` + empty-history
failure is specific to **Balance Migration**, not to closure in general.

### Separate, more common glitch: blank `Total interest for this period: $`
Seen on 4 of 13 accounts, and it is **not** tied to closure: acct 10000627167
was open and still had it blank. Independent of the Balance Migration failure,
though the two Balance Migration accounts show it as well:

| Account | State | Blank total interest |
|---|---|---|
| 10000627167 | open | yes |
| 10001167979 | Balance Migration | yes (full degradation) |
| 10000970018 | Balance Migration | yes (full degradation) |
| 10001167510 | Direct Credit payout | yes (otherwise fine) |

The figure is always present and correct in the SOA itself, so it costs nothing
operationally: but it means the Customer Details page cannot be trusted for
that field on any account.

## Rebuilding the toolchain after a container recycle
The cloud container is ephemeral: on 5 Oct 2026 it was reclaimed and every
working file was gone. Everything needed to rebuild now lives in this project:

| Project doc | Restores |
|---|---|
| `claude/soa-template_head.html` | the CSS (the layout spec, executable) |
| `claude/soa-build_soa.py` | JSON → HTML + PDF, incl. the balance chain check |
| `claude/soa-parse_soa_html.py` | Horizon SOA HTML → JSON |
| `claude/soa-make_logo.py` | regenerates `logo_b64.txt` |

Recovery: `project_read` those four to disk, then
`python3 make_logo.py <any Customer Details PDF>`.

**Do not try to restore the logo by re-typing base64.** It is ~45KB and will be
silently truncated, producing a PNG whose header parses but whose pixel data is
a broken stream. `make_logo.py` instead extracts the wordmark from the dark-teal
(`~#0B2828`) logo printed top-left on every Customer Details PDF, mattes it to
`#1C3132` with alpha taken from the white background, and scales it for the
banner: so the logo is always regenerable from the job in hand. It self-verifies
by reloading the PNG after writing.

## Run log
| Account | Input | Rows | Flagged | Pages out | Chain breaks |
|---|---|---|---|---|---|
| 10001459594 | 78-page rasterised PDF (OCR) | 2,012 | 44 | 74 | 0 |
| 10000627167 | Horizon HTML | 3,352 | 55 | 122 | 0 |
| 10001167979 | Horizon HTML | 2,875 | 9 | 105 | 0 |
| 10001037413 | Horizon HTML | 2,644 | 1 | 97 | 0 |
| 10001133359 | Horizon HTML | 2,490 | 22 | 91 | 0 |
| 10000970018 | Horizon HTML | 3,427 | 21 | 125 | 0 |
| 10001404007 | Horizon HTML | 2,166 | 25 | 79 | 0 |
| 10000630336 | Horizon HTML | 2,309 | 33 | 85 | 0 |
| 10001081999 | Horizon HTML | 2,903 | 48 | 106 | 0 |
| 10001197634 | Horizon HTML | 2,358 | 70 | 86 | 0 |
| 10000899629 | Horizon HTML | 3,071 | 94 | 112 | 0 |
| 10001093600 | Horizon HTML | 3,092 | 74 | 113 | 0 |
| 10001167510 | Horizon HTML | 2,874 | 46 | 105 | 0 |
