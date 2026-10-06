#!/usr/bin/env python3
"""MoneyMe Statement of Account (SOA) builder.  JSON in -> HTML + PDF out."""
import json, sys, os, subprocess, base64, argparse, html as _html

HERE = os.path.dirname(os.path.abspath(__file__))

# --- find a Chromium-family browser to print the PDF -------------------------
# Any of Chrome / Chromium / Edge works; they share the --print-to-pdf flag.
# Override with:  set MONEYME_CHROME=C:\path\to\chrome.exe   (or export on *nix)
_CANDIDATES = [
    os.environ.get("MONEYME_CHROME"),
    # Windows
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
    # macOS
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge",
    "/Applications/Chromium.app/Contents/MacOS/Chromium",
    # Linux / WSL / containers
    "/opt/pw-browsers/chromium",
    "/usr/bin/google-chrome", "/usr/bin/chromium", "/usr/bin/chromium-browser",
    "/usr/bin/microsoft-edge",
]


def find_browser():
    from shutil import which
    for c in _CANDIDATES:
        if c and os.path.exists(c):
            return c
    for n in ("chrome", "google-chrome", "chromium", "chromium-browser", "msedge"):
        p = which(n)
        if p:
            return p
    raise SystemExit(
        "No Chrome/Chromium/Edge found. Install one, or point MONEYME_CHROME at it:\n"
        "  Windows:  set MONEYME_CHROME=C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe\n"
        "  macOS/Linux:  export MONEYME_CHROME=/path/to/chrome")


def logo_data_uri():
    return "data:image/png;base64," + open(os.path.join(HERE, "logo_b64.txt")).read().strip()


def e(v):
    return _html.escape("" if v is None else str(v))


def money(v):
    if v is None or v == "":
        return "0.00"
    if isinstance(v, str):
        s = v.replace("$", "").replace(",", "").strip()
        if s in ("", "-"):
            return "0.00"
        try:
            v = float(s)
        except ValueError:
            return v
    return f"{v:,.2f}"


def dollars(v):
    return "$" + money(v)


def check_chain(tx):
    """Transcription/parse safety net. Changes nothing -- only reports rows where
    balance != prev + debit - credit (or != prev when flagged) by more than 1c.
    1c drift on Daily Interest is normal: Horizon rounds the displayed debit but
    carries full precision in the balance."""
    bad, prev = [], None
    for i, t in enumerate(tx):
        b = float(str(t.get("balance", 0)).replace(",", "").replace("$", ""))
        d = float(str(t.get("debit", 0)).replace(",", "").replace("$", ""))
        c = float(str(t.get("credit", 0)).replace(",", "").replace("$", ""))
        flagged = bool(t.get("flag_debit") or t.get("flag_credit"))
        if prev is not None:
            expect = prev if flagged else prev + d - c
            if abs(expect - b) > 0.011:
                bad.append((i + 1, t["date"], t["type"], round(expect, 2), b))
        prev = b
    return bad


def build_html(d):
    css = open(os.path.join(HERE, "template_head.html")).read()
    ref = e(d["reference_number"])
    cust, acct = d["customer"], d["account"]

    def keep_indent(t):
        n = len(t) - len(t.lstrip(" "))
        return "&nbsp;" * n + e(t.lstrip(" "))

    addr_lines = "<br>".join(keep_indent(l) for l in cust["address_lines"])

    def amount(val, flag):
        txt = money(val)
        return f'<span class="fail">{e(flag)} {txt}</span>' if flag else txt

    rows = ['<tr class="head"><td class="c-date">Date</td><td class="c-type">Trans Type</td>'
            '<td class="c-deb">Debit</td><td class="c-cred">Credit</td>'
            '<td class="c-bal">Balance</td></tr>']
    for t in d["transactions"]:
        rows.append(
            "<tr>"
            f'<td class="c-date">{e(t["date"])}</td>'
            f'<td class="c-type">{e(t["type"])}</td>'
            f'<td class="c-deb">{amount(t.get("debit", 0), t.get("flag_debit", ""))}</td>'
            f'<td class="c-cred">{amount(t.get("credit", 0), t.get("flag_credit", ""))}</td>'
            f'<td class="c-bal">{money(t.get("balance", 0))}</td>'
            "</tr>")

    period = f'{e(acct["period_from"])} - {e(acct["period_to"])}'
    body = f"""
<div class="banner"><img src="{logo_data_uri()}" alt="MONEYME"></div>

<div class="ref-strip">Reference number {ref}</div>

<div class="salutation">Hi {e(cust["first_name"])},</div>
<div class="ref-line">Reference number {ref}</div>

<div class="statement">
  <h1 class="soa-title">YOUR ACCOUNT STATEMENT</h1>

  <table class="meta"><tr>
    <td>Reference number: {ref}</td>
    <td>{e(d["statement_date"])}</td>
  </tr></table>

  <table class="summary"><tr>
    <td class="who">{e(cust["full_name"])}<br>{addr_lines}</td>
    <td class="acct">
      <b>Account Summary</b><br>
      <b>Opening Balance:</b> {dollars(acct["opening_balance"])}<br>
      <b>Closing Balance:</b> {dollars(acct["closing_balance"])}<br>
      <b>Statement Period:</b> {period}<br>
      <b>Contract Type:</b> {e(acct["contract_type"])}
    </td>
  </tr></table>

  <div class="legend">X=Failed transaction<br>P=Pending transaction</div>

  <table class="txn">{''.join(rows)}</table>
</div>

<div class="closing">
  <div class="totals">
    <b>Total interest for this period:</b> {dollars(acct["total_interest"])}<br>
    <b>Outstanding charges:</b> {dollars(acct["outstanding_charges"])}<br>
    <b>Current arrears:</b> {dollars(acct["current_arrears"])}
  </div>
  <div class="signoff">
    If you&rsquo;ve got any further queries, give us a buzz on
    <span class="phone">1300&nbsp;669&nbsp;059</span>.
    <div class="cheers">Cheers,<br><span class="team">Team MONEYME</span></div>
  </div>
  <div class="contact">
    <span class="lbl">T</span> 1300 669 059 | <span class="lbl">E</span> hello@moneyme.com.au<br>
    Level 3, 131 Macquarie Street, Sydney NSW 2000<br>
    MoneyMe Financial Group Pty Ltd | ABN 40 163 691 236 | Australian Credit Licence Number 442218
  </div>
</div>
</body>
</html>
"""
    return css + body


def to_pdf(html_path, pdf_path):
    subprocess.run([find_browser(), "--headless", "--disable-gpu", "--no-sandbox",
                    "--no-pdf-header-footer", "--run-all-compositor-stages-before-draw",
                    "--virtual-time-budget=20000", f"--print-to-pdf={pdf_path}",
                    "file://" + os.path.abspath(html_path)],
                   check=True, capture_output=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("data"); ap.add_argument("-o", "--out", default=None)
    a = ap.parse_args()
    d = json.load(open(a.data))
    bad = check_chain(d["transactions"])
    if bad:
        print(f"!! {len(bad)} row(s) break the balance chain -- CHECK:")
        for r in bad:
            print(f"   row {r[0]:>5}  {r[1]}  {r[2]:<22} expected {r[3]:>13,.2f}  got {r[4]:>13,.2f}")
        print("   (values left exactly as supplied -- nothing was recalculated)")
    base = a.out or os.path.splitext(a.data)[0]
    hp, pp = base + ".html", base + ".pdf"
    open(hp, "w").write(build_html(d))
    to_pdf(hp, pp)
    print("wrote", hp, "and", pp)


if __name__ == "__main__":
    main()
