#!/usr/bin/env python3
import re, sys

GLOBAL_TYPE_WIDTH = 6  # len('bindel')


def col(val, width):
    """'value,' left-justified to width+1 — comma right after value, spaces after."""
    return (val + ",").ljust(width + 1)


def parse_bind(line):
    m = re.match(r"^(bind[a-z]*)\s*=\s*", line)
    if not m:
        return None
    bt = m.group(1)
    rest = line[m.end() :]

    parts = rest.split(",", 3)
    if len(parts) < 3:
        return None

    mod = parts[0].strip()
    key = parts[1].strip()
    disp = parts[2].strip().rstrip(",").strip()
    args_raw = parts[3].strip() if len(parts) > 3 else ""

    if args_raw.startswith("#"):
        return {
            "type": bt,
            "mod": mod,
            "key": key,
            "disp": disp,
            "args": "",
            "comment": args_raw[1:].strip(),
        }
    else:
        return {
            "type": bt,
            "mod": mod,
            "key": key,
            "disp": disp,
            "args": args_raw,
            "comment": "",
        }


def fmt_section(raw_lines):
    parsed = [(l, parse_bind(l)) for l in raw_lines]
    binds = [p for _, p in parsed if p is not None]

    if not binds:
        return [l for l, _ in parsed]

    mw = max(len(b["mod"]) for b in binds)
    kw = max(len(b["key"]) for b in binds)
    dw = max(len(b["disp"]) for b in binds)
    tw = GLOBAL_TYPE_WIDTH

    result = []
    for line, p in parsed:
        if p is None:
            result.append(line)
            continue

        t = p["type"].ljust(tw)
        mo = col(p["mod"], mw)
        k = col(p["key"], kw)

        if p["args"]:
            d = col(p["disp"], dw)
            s = f"{t} = {mo} {k} {d} {p['args']}"
        elif p["comment"]:
            d = col(p["disp"], dw)
            s = f"{t} = {mo} {k} {d} # {p['comment']}"
        else:
            # no args, no comment — no trailing comma added
            s = f"{t} = {mo} {k} {p['disp']}"

        result.append(s)
    return result


with open(sys.argv[1]) as f:
    lines = [l.rstrip("\n") for l in f]

sections, cur = [], []
for line in lines:
    if line.strip() == "":
        if cur:
            sections.append(("lines", cur))
            cur = []
        sections.append(("blank", []))
    else:
        cur.append(line)
if cur:
    sections.append(("lines", cur))

output = []
for kind, sec in sections:
    if kind == "blank":
        output.append("")
    else:
        output.extend(fmt_section(sec))

print("\n".join(output), end="")
