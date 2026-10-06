#!/usr/bin/env python3
"""Parse a Horizon SOA email HTML into the SOA generator's JSON schema.
Values come straight from the DOM; the failed/pending flag comes from the
cell's own `color:red` style (or an 'X '/'P ' prefix in the cell text)."""
import sys, json, re
from bs4 import BeautifulSoup

DATE = re.compile(r"^\d{2}/\d{2}/\d{4}$")
MONTH = (r"(?:January|February|March|April|May|June|July|August|"
         r"September|October|November|December)")


def text(el):
    return re.sub(r"\s+", " ", el.get_text(" ", strip=True)).strip()


def parse(path):
    soup = BeautifulSoup(open(path, encoding="utf-8-sig").read(), "lxml")
    body = text(soup)

    def grab(pat):
        m = re.search(pat, body)
        return m.group(1).strip() if m else None

    out = {}
    out["reference_number"] = grab(r"Reference number:?\s*(\d+)")
    out["greeting_name"] = grab(r"Hi ([^,]+),")
    out["statement_date"] = grab(rf"(\d{{1,2}}\s+{MONTH}\s+\d{{4}})")

    txn_table = None
    for t in soup.find_all("table"):
        tds = t.find_all("td", recursive=True)[:2]
        if len(tds) == 2 and text(tds[0]) == "Date" and text(tds[1]) == "Trans Type":
            txn_table = t
            break
    if txn_table is None:
        raise SystemExit("transaction table not found")

    rows = []
    for tr in txn_table.find_all("tr"):
        tds = tr.find_all("td", recursive=False)
        if len(tds) < 5:
            continue
        vals = [text(td) for td in tds[:5]]
        if not DATE.match(vals[0]):
            continue

        def cell(i):
            raw = vals[i]
            red = "color:red" in (tds[i].get("style") or "").replace(" ", "").lower()
            m = re.match(r"^([XP])\s+(.*)$", raw)
            flag = m.group(1) if m else ("X" if red else "")
            return (m.group(2) if m else raw), flag

        deb, fdeb = cell(2)
        cred, fcred = cell(3)
        rows.append({"date": vals[0], "type": vals[1], "debit": deb, "credit": cred,
                     "balance": vals[4], "flag_debit": fdeb, "flag_credit": fcred})
    out["transactions"] = rows

    out["account"] = {
        "opening_balance":     grab(r"Opening Balance\s*:?\s*\$?([\d,]+\.\d\d)"),
        "closing_balance":     grab(r"Closing Balance\s*:?\s*\$?([\d,]+\.\d\d)"),
        "contract_type":       grab(r"Contract Type\s*:?\s*([A-Za-z]+)"),
        "total_interest":      grab(r"Total interest for this period:\s*\$?([\d,]+\.\d\d)"),
        "outstanding_charges": grab(r"Outstanding charges:\s*\$?([\d,]+\.\d\d)"),
        "current_arrears":     grab(r"Current arrears:\s*\$?([\d,]+\.\d\d)"),
    }
    per = grab(r"Statement Period\s*:?\s*(\d{2}/\d{2}/\d{4}\s*-\s*\d{2}/\d{2}/\d{4})")
    if per:
        a, b = [x.strip() for x in per.split("-")]
        out["account"]["period_from"], out["account"]["period_to"] = a, b
    return out


if __name__ == "__main__":
    d = parse(sys.argv[1])
    outp = sys.argv[2] if len(sys.argv) > 2 else "parsed.json"
    print(json.dumps({k: v for k, v in d.items() if k != "transactions"}, indent=1))
    print("transactions:", len(d["transactions"]))
    print("flagged:", sum(1 for t in d["transactions"] if t["flag_debit"] or t["flag_credit"]))
    print("first:", d["transactions"][0])
    print("last :", d["transactions"][-1])
    json.dump(d, open(outp, "w"), indent=1)
