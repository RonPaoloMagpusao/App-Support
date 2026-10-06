#!/usr/bin/env python3
"""Pre-commit check for the App Support knowledge base.

Fails on: broken relative links, em dashes, non-MoneyMe email addresses,
Australian mobile numbers other than the 0400000000 placeholder, and common
credential patterns. Run from the repo root: python3 tools/check.py
"""
import os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TEXT_EXT = {".md", ".sql", ".html", ".py", ".txt"}

ALLOWED_EMAIL = re.compile(
    r"@(moneyme\.com\.au|moneyme\.net|example\.com)$|^(mail@mail\.com|testing@gmail\.com|x@y\.com|defender-noreply@microsoft\.com)$",
    re.I)
EMAIL = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")
MOBILE = re.compile(r"(?<!\d)(?:\+?61\s?4|04)\d{2}[\s-]?\d{3}[\s-]?\d{3}(?!\d)")
SECRETS = [
    re.compile(r"SG\.[A-Za-z0-9_-]{16,}\.[A-Za-z0-9_-]{16,}"),          # SendGrid key
    re.compile(r"\bAC[0-9a-f]{32}\b"),                                   # Twilio SID
    re.compile(r"(?i)(password|pwd)\s*=\s*['\"][^'\"<]{4,}['\"]"),       # literal password
    re.compile(r"(?i)(Data Source|Server)\s*=\s*[^;<]+;.*(Password|Pwd)\s*="),  # conn string
    re.compile(r"(?i)bearer\s+[A-Za-z0-9._-]{20,}"),
    re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----"),
    re.compile(r"[A-Za-z0-9+/]{24,}={1,2}"),                             # base64 blob (encrypted value)
    re.compile(r"(?i)(?<!~)\b[0-9a-f]{32,}\b"),                           # hex hash (not a ~space key)
]
# Known binary payloads stored as text (not credentials)
SKIP_FILES = {".claude/skills/moneyme-soa/scripts/logo_b64.txt"}  # MONEYME wordmark PNG
LINK = re.compile(r"\[[^\]]*\]\(([^)\s]+)\)")

def files():
    for d, dirs, fs in os.walk(ROOT):
        dirs[:] = [x for x in dirs if x not in {".git", "tools"}]
        for f in fs:
            if os.path.splitext(f)[1] in TEXT_EXT:
                yield os.path.join(d, f)

problems = []
for path in files():
    rel = os.path.relpath(path, ROOT)
    if rel.replace(os.sep, "/") in SKIP_FILES:
        continue
    text = open(path, encoding="utf-8").read()
    for i, line in enumerate(text.split("\n"), 1):
        if "—" in line:
            problems.append(f"{rel}:{i}: em dash")
        for m in EMAIL.finditer(line):
            e = m.group(0)
            if not ALLOWED_EMAIL.search(e):
                problems.append(f"{rel}:{i}: email address {e}")
        for m in MOBILE.finditer(line):
            if re.sub(r"\D", "", m.group(0)) not in {"0400000000", "61400000000"}:
                problems.append(f"{rel}:{i}: mobile number {m.group(0)}")
        for rx in SECRETS:
            if rx.search(line) and "REDACTED" not in line:
                problems.append(f"{rel}:{i}: possible credential ({rx.pattern[:30]})")
    if path.endswith(".md"):
        in_code = False
        for i, line in enumerate(text.split("\n"), 1):
            if line.strip().startswith("```"):
                in_code = not in_code
            if in_code:
                continue
            for m in LINK.finditer(line):
                target = m.group(1)
                if re.match(r"^(https?:|mailto:|#)", target):
                    continue
                target = target.split("#")[0]
                if not target:
                    continue
                if not os.path.exists(os.path.normpath(os.path.join(os.path.dirname(path), target))):
                    problems.append(f"{rel}:{i}: broken link {m.group(1)}")

for p in problems:
    print(p)
print(f"\n{len(problems)} problem(s)")
sys.exit(1 if problems else 0)
