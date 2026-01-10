import json
import subprocess
import sys
import os

def get_json(command):
    try:
        output = subprocess.check_output(command, shell=True)
        return json.loads(output)
    except subprocess.CalledProcessError as e:
        print(f"Error running command '{command}': {e}", file=sys.stderr)
        return None
    except json.JSONDecodeError as e:
        print(f"Error decoding JSON from '{command}': {e}", file=sys.stderr)
        return None

def is_adjacent(w1, w2, threshold=150):
    # w1 and w2 are dicts with 'at' [x, y] and 'size' [w, h]
    x1, y1 = w1['at']
    w1_w, w1_h = w1['size']
    r1 = x1 + w1_w
    b1 = y1 + w1_h

    x2, y2 = w2['at']
    w2_w, w2_h = w2['size']
    r2 = x2 + w2_w
    b2 = y2 + w2_h

    # Debug distances
    # print(f"Checking {w2.get('class')}: x_dist={min(abs(x1-r2), abs(r1-x2))}, y_dist={min(abs(y1-b2), abs(b1-y2))}")

    # Vertical overlap (y-ranges overlap)
    overlap_vertical = (y1 < b2) and (y2 < b1)
    
    # Horizontal overlap (x-ranges overlap)
    overlap_horizontal = (x1 < r2) and (x2 < r1)

    # w2 is LEFT of w1 if w2.right ~ w1.left
    dist_l = abs(x1 - r2)
    if dist_l < threshold and overlap_vertical:
        return "l", dist_l
    
    # w2 is RIGHT of w1 if w1.right ~ w2.left
    dist_r = abs(r1 - x2)
    if dist_r < threshold and overlap_vertical:
        return "r", dist_r

    # w2 is UP of w1 if w2.bottom ~ w1.top
    dist_u = abs(y1 - b2)
    if dist_u < threshold and overlap_horizontal:
        return "u", dist_u

    # w2 is DOWN of w1 if w1.bottom ~ w2.top
    dist_d = abs(b1 - y2)
    if dist_d < threshold and overlap_horizontal:
        return "d", dist_d

    return None, 0

def main():
    # active_window = get_json("hyprctl activewindow -j")
    # Use the /tmp files if they exist and are recent to match the QML logic, 
    # but for this script, let's just query fresh to be sure.
    active_window = get_json("hyprctl activewindow -j")
    clients = get_json("hyprctl clients -j")

    if not active_window or not clients:
        print("Could not get window info.")
        return

    # If active window is not a valid client (e.g. empty or special), we might need to handle it.
    if not active_window.get('address'):
        print("No active window found.")
        return

    aw_addr = active_window['address']
    aw_ws = active_window['workspace']['id']
    
    print(f"\nActive Window: {active_window.get('class')} ({active_window.get('title')})")
    print(f"  Address: {aw_addr}")
    print(f"  Workspace: {aw_ws}")
    print(f"  Geometry: {active_window['at']} {active_window['size']}")
    print("-" * 40)

    print("Adjacent Windows:")
    count = 0
    # directions = {"l": False, "r": False, "u": False, "d": False}
    adj_list = []
    
    for client in clients:
        # Skip self
        if client['address'] == aw_addr:
            continue
        
        # Skip other workspaces (usually adjacency implies same workspace, though not strictly required for 'touching' across monitors, but usually desired)
        if client['workspace']['id'] != aw_ws:
            continue
        
        # Check adjacency
        adj_type, dist = is_adjacent(active_window, client)
        if adj_type:
            count += 1
            # directions[adj_type] = True
            
            item = {
                "dir": adj_type,
                "dist": dist,
                "x": client['at'][0],
                "y": client['at'][1],
                "w": client['size'][0],
                "h": client['size'][1],
                "class": client.get('class'),
                "title": client.get('title'),
                "focusHistoryID": client.get('focusHistoryID'),
                "address": client['address']
            }
            adj_list.append(item)

            print(f"[{adj_type.upper()}] {client.get('class')} ({client.get('title')})")
            print(f"    Address: {client['address']}")
            print(f"    Geometry: {client['at']} {client['size']}")
            print(f"    Dist: {dist}")
            print(f"    FocusHistoryID: {client.get('focusHistoryID')}")

    if count == 0:
        print("None found.")
        
    print(f"ADJACENT:{json.dumps(adj_list)}")

if __name__ == "__main__":
    main()
