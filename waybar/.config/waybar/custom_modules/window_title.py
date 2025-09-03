#!/usr/bin/env python3
import sys
import subprocess
import json
import os
import ast

output_name = sys.argv[1] if len(sys.argv) > 1 else None

REWRITE_PATH = os.path.expanduser("~/.config/waybar/title_rewrites.ini")
REWRITES = []
if os.path.exists(REWRITE_PATH):
    with open(REWRITE_PATH, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            if "=" in line:
                key, _, val = line.partition("=")
                key = key.strip()
                val = val.strip()
                if key.startswith('"') and key.endswith('"'):
                    key = ast.literal_eval(key)
                if val.startswith('"') and val.endswith('"'):
                    val = ast.literal_eval(val)
                REWRITES.append((key, val))


def rewrite_title(title):
    for pattern, replacement in REWRITES:
        if pattern == "/":
            # Only replace if the whole title is exactly "/"
            if title.strip() == "/":
                title = replacement
        else:
            title = title.replace(pattern, replacement)
    return title.strip() if title.strip() else "  Desktop"


# TEST MODE: run with argument "TEST" to debug replacements
if output_name == "TEST":
    print(rewrite_title("nvim ~/.config/waybar/config_modules.jsonc"))
    sys.exit(0)

# Get monitor and client info
monitors = json.loads(subprocess.check_output(["hyprctl", "monitors", "-j"], text=True))
clients = json.loads(subprocess.check_output(["hyprctl", "clients", "-j"], text=True))

result = {}

for mon in monitors:
    if output_name and mon["name"] != output_name:
        continue
    ws_id = mon["activeWorkspace"]["id"]
    ws_clients = [c for c in clients if c["workspace"]["id"] == ws_id]
    if ws_clients:
        focused_client = min(ws_clients, key=lambda c: c["focusHistoryID"])
        title = focused_client["title"]
    else:
        title = ""
    rewritten = rewrite_title(title)
    if output_name:
        print(rewritten)
        sys.exit(0)
    result[mon["name"]] = rewritten

if not output_name:
    print(json.dumps(result))

