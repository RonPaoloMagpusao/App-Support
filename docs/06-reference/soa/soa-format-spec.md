# SOA (Statement of Account) layout spec

Layout spec for rebuilding a Horizon Statement of Account by hand when Horizon will not generate one, plus the extraction workflow and the Horizon glitches seen so far.

Last reviewed: 23 September 2026
Sources: Reverse-engineered from a Horizon "Loan Document Preview" SOA printed via Microsoft Print to PDF, verified page for page; runs on seven accounts, 27 August to 1 September 2026. Why SOAs fail to generate: [../../02-runbooks/soa-generation.md](../../02-runbooks/soa-generation.md)

Pagination matches the reference exactly (11/28/28/28/28/2 rows plus a closing page) and text overlays with zero visible offset.

## Page setup

- Letter (612 x 792 pt, 8.5 x 11 in).
- `@page` margins: **top 0.399in, right 0.378in, bottom 0.47in, left 0.473in**.
- Page 1 only: `body { padding-top: 0.071in }`. The banner sits lower than continuation-page content.
- Font: Arial / Helvetica throughout. Body **11pt**, line-height 1.5.

## Page 1 structure, top to bottom

| Element | Spec |
| --- | --- |
| Green banner | `#BAEA02`, full content width, height 1.247in. MONEYME wordmark 1.435 x 0.277in, inset 0.845in left, 0.505in top |
| Reference strip | Right-aligned, 11px, `#767676`, padding-right 11px, margin-top 13px |
| `Hi <FirstName>,` | margin-left 0.100in, margin-top 38px |
| `Reference number <ref>` | margin-left 0.100in, margin-top 15px |
| Statement block | Container: margin-left 0.796in, margin-right 0.790in |
| `YOUR ACCOUNT STATEMENT` | 13.75pt bold, margin-top 33px |
| Meta row | Two-column 50/50 table, padding-left 4px, margin-top 20px. Left: `Reference number: <ref>`. Right: statement date in `27 August 2026` style |
| Account summary box | 1px `#ccc`, two cells 50/50, padding 9px, margin-top 20px. Left cell **vertically centred**: name and address lines. Right cell **top-aligned**: Account Summary, Opening Balance, Closing Balance, Statement Period, Contract Type (labels bold, values plain) |
| Legend | Bold, two lines, margin-top 17px: `X=Failed transaction` / `P=Pending transaction` |
| Transaction table | margin-top 19px, 11px font, line-height 1.15, 1px solid black collapsed borders, cell padding `10.185px 6px`, giving a row pitch of 0.354in |

Column widths: Date 15%, Trans Type 35%, Debit 15%, Credit 15%, Balance 20%.

The header row is a normal `<tr>` inside `<tbody>`. It must **not** repeat on continuation pages, so do not use `<thead>`.

## Closing page

`page-break-before: always`. In the reference the closing block always starts on its own page.

| Element | Spec |
| --- | --- |
| Totals | margin-left 0.302in, margin-top 17px, line-height 0.25in. Bold labels: `Total interest for this period:`, `Outstanding charges:`, `Current arrears:` |
| Sign-off | margin-left 0.119in, margin-top 64px. "If you've got any further queries, give us a buzz on **1300 669 059**." Phone in `#ADCB07` bold |
| Cheers | margin-top 20px, `Cheers,` then `Team MONEYME` in bold |
| Contact footer | Centred, 6.9pt, line-height 0.1535in, `#3f3f3f`, margin-top 43px. Bold `T` and `E` labels. Three lines: phone and email; Level 3, 131 Macquarie Street, Sydney NSW 2000; MoneyMe Financial Group Pty Ltd, ABN 40 163 691 236, Australian Credit Licence Number 442218 |

The contact footer appears on the closing page only. It is not a running footer.

## Brand colours

| Use | Colour |
| --- | --- |
| Banner green | `#BAEA02` |
| Phone number green | `#ADCB07` |
| Wordmark | `#1C3132` |
| Summary box border | `#CCCCCC` |
| Reference strip grey | `#767676` |

## Rendering

`build_soa.py` (JSON in, HTML and PDF out) via headless Chromium with `--print-to-pdf --no-pdf-header-footer`. The scripts live with Ron's Claude project, not in this repo.

Manual print settings that reproduce it: Letter, Margins **Default**, Scale **100%**, Headers and footers **off**, Background graphics **on**.

## Failed and pending markers

Resolved on account 10001459594, 27 August 2026.

- Horizon prefixes the flag to the **amount cell**, not the Trans Type, and renders the whole cell in pure red `#FF0000`. Example: a failed Split Sched shows `X 200.87` in the Credit column.
- A flagged row does **not** move the running balance (balance equals previous balance).
- The extractor detects flags by red pixels rather than OCR, which is far more reliable than reading a single `X` glyph.

## Agreed workflow

Agreed 27 August 2026.

- **Balances are reproduced exactly as supplied.** Never recalculate the Balance column, Closing Balance or Total interest.
- `build_soa.py` runs a read-only chain check and prints any row where `balance != prev + debit - credit` by more than 1c, purely to catch a transcription slip. A 1c drift on `Daily Interest` rows is normal in Horizon (the displayed debit is rounded; the balance carries full precision) and is ignored.

### Preferred input: the Horizon SOA HTML

Ask for the raw `.html` Horizon produces first. `parse_soa_html.py` reads values straight from the DOM: no OCR, no transcription risk.

- Transaction rows come from the `Date` / `Trans Type` table.
- The failed or pending flag comes from the cell's own `color:red` style and/or an `X ` / `P ` prefix in the cell text.
- Header, summary and totals figures come from the document text.

Result on account 10000627167: 3,352 rows parsed, 55 flagged, zero balance-chain breaks, in seconds. Compare about five minutes of OCR for the 78-page PDF of account 10001459594.

### Fallback: a rasterised PDF

A PDF printed via Microsoft Print to PDF has no extractable text. `ocr_soa.py` plus `run_ocr.py`:

1. `pdftoppm -r 300 -gray` for OCR, `-r 150` colour for red-flag detection.
2. Find gridlines; keep every row band (heights vary because Trans Type wraps).
3. Stack each column's cells into one tall strip with white gutters so tesseract emits one line per cell. Per-column character whitelists (`0123456789/` for dates, `0123456789,.-XP ` for amounts).
4. A wrapped cell breaks strip alignment; that column falls back to per-cell OCR with lines joined.
5. Flags are read from `#FF0000` pixels per cell.
6. Validate: `balance == prev + debit - credit`, or `== prev` when flagged. On account 10001459594 this reconciled 2,012 of 2,012 rows with zero breaks, which also proves no row was dropped or duplicated at a page boundary.

## Known Horizon glitches

- `[Application].[EmailHeader]`, `[Application].[EmailSignature]`, `[Application].[EmailFooter]`: unresolved merge tokens where the banner, sign-off and ABN contact block should be. All three seen on account 10001167979.
- Customer name and address masked as `xxxx` (account 10001459594).
- `Total interest for this period: $` with no amount on the Customer Details page (account 10000627167). The figure is present in the SOA itself.
- A "Download our MONEYME App today" block with app-store badges appears in the generated SOA but not in the reference. Drop it.
- The Customer Details page and the SOA legitimately disagree on opening balance, statement period and total interest: the SOA is full account history, Customer Details is the current statement period. Closing balance, outstanding charges and current arrears match. Use the SOA's own figures; take only name and address from Customer Details.
- Customer Details can be near useless. On account 10001167979 it showed opening $0.00, closing $0.00, statement period `01/01/0001 - 27/08/2026` (null start date), a blank `$` for total interest, and "End of transaction history" with no rows. The SOA itself was complete and correct (opening $250.00, period 04/03/2021 to 25/05/2026, interest $16,039.38). Treat Customer Details as a source for name and address only.
- The salutation field can contain the literal placeholder `Other`: account 10001037413 came through as "Other" followed by the customer's name. Drop it; never print it on a customer-facing statement.
- **The statement date is not always the day you run it.** Account 10001037413 was 1 September 2026 while the earlier three were 27 August 2026. `parse_soa_html.py` reads it from the SOA rather than hardcoding it.
- The last row balance can sit 1c below the stated Closing Balance (account 10001404007: final row $8,019.74, Closing Balance $8,019.75, Customer Details also $8,019.75). Same Daily Interest rounding drift. Not a transcription error; reproduce both figures as given.

## Pattern: degraded Customer Details means the account was closed by Balance Migration

Exact correlation across the accounts done so far.

| Account | Last transaction | Customer Details page |
| --- | --- | --- |
| 10001459594 | Daily Interest (open) | Healthy |
| 10000627167 | Direct Credit (open) | Healthy |
| 10001167979 | **Balance Migration to $0.00** | **Degraded** |
| 10001037413 | Accounting Fee (open) | Healthy |
| 10001133359 | Accounting Fee (open) | Healthy |
| 10000970018 | **Balance Migration to $0.00** | **Degraded** |
| 10001404007 | Daily Interest (open) | Healthy |

"Degraded" is the same four symptoms every time: opening $0.00, closing $0.00, statement period `01/01/0001 - <today>`, blank `$` for total interest, and "End of transaction history" with no rows, while the SOA itself is complete. Only outstanding charges and current arrears survive.

Likely cause, unverified: the Customer Details query cannot resolve a statement period once an account has been migrated or closed out, and the null start date (`01/01/0001`, which is `DateTime.MinValue`) yields an empty transaction window. Worth raising as an MHD Problem: two for two on closed accounts.

## Run log

| Account | Input | Rows | Flagged | Pages out | Chain breaks |
| --- | --- | --- | --- | --- | --- |
| 10001459594 | 78-page rasterised PDF (OCR) | 2,012 | 44 | 74 | 0 |
| 10000627167 | Horizon HTML | 3,352 | 55 | 122 | 0 |
| 10001167979 | Horizon HTML | 2,875 | 9 | 105 | 0 |
| 10001037413 | Horizon HTML | 2,644 | 1 | 97 | 0 |
| 10001133359 | Horizon HTML | 2,490 | 22 | 91 | 0 |
| 10000970018 | Horizon HTML | 3,427 | 21 | 125 | 0 |
| 10001404007 | Horizon HTML | 2,166 | 25 | 79 | 0 |
