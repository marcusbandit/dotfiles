# caelestia local patches

Local QML customizations for **caelestia-shell**, kept as unified diffs so they
survive package upgrades.

## Layout

| Path | Role |
|------|------|
| `/etc/xdg/quickshell/caelestia` | pristine upstream, owned by the `caelestia-shell` package |
| `~/.config/quickshell/caelestia` | working copy the shell actually runs (`launch-caelestia` → `qs -p`) |
| `~/.config/quickshell/caelestia-patches/` | this archive: `patches/*.patch` + the `caelestia-patches` tool |

The working copy is a plain copy of upstream with the patches applied on top.
`launch-caelestia` runs that copy; the system plugin (`/usr/lib/qt6/qml/Caelestia`)
supplies the C++ types, so QML-only tweaks need no rebuild.

## After a caelestia-shell upgrade

```sh
caelestia-patches sync      # back up copy, recopy upstream, reapply patches
launch-caelestia
```

If a patch fails (upstream moved the code), `caelestia-patches status` shows the
conflict; re-port it by hand in the working copy, then `caelestia-patches regen`
to save the updated diff.

## After editing the QML yourself

```sh
# edit files under ~/.config/quickshell/caelestia ...
caelestia-patches regen     # re-diff and update the .patch files
```

To start a brand-new patch, add a `patches/NN-name.patch` containing at least the
`+++ b/<relpath>` header lines for the files it covers, then `regen` fills in the
diff. (Or just hand-write the diff.)

## Patches

- **01-screenshot-open-action.patch**: `modules/areapicker/Picker.qml`
  - strip the `file://` prefix before piping into `wl-copy`
  - add an **Open** action to the "Screenshot copied" notification that opens the
    shot in `imv`
- **02-bluetooth-mac-sort.patch**: bar popout + nexus bluetooth pages
  - sort bluetooth lists so devices whose name is just a raw MAC address
    (unnamed) sink to the bottom, below properly named ones
  - covers `modules/bar/popouts/Bluetooth.qml`,
    `modules/nexus/pages/BluetoothPage.qml`,
    `modules/nexus/pages/bluetooth/BluetoothPairing.qml`
- **03-howdy-face-unlock.patch**: howdy face unlock on the lock screen
- **04-faceunlock-indicator.patch**: face-scan indicator pill, driven by the
  `faceunlock start/stop` IPC from the howdy watcher service
- **05-dashboard-declutter.patch**: `modules/dashboard/Dash.qml` +
  `modules/dashboard/dash/Media.qml`
  - remove the small weather widget, the user/avatar card, and the resources
    (performance) column from the main dashboard tab
  - remaining layout is a single row: date/time, calendar, media, plus a
    battery tank (reused from the performance tab) on the right when a laptop
    battery is present
  - related but NOT part of the patch: the Weather tab is hidden natively via
    `dashboard.showWeather: false` in `~/.config/caelestia/shell.json`
  - `dash/Media.qml`: on banditbox this hunk only adds an implicitHeight (the
    card used to be stretched by the old two-row grid); the media image is
    kept, not dropped. The `rounding.large` change for the main dash cards
    lives in `Dash.qml`, within this same patch (see 06 for the matching
    performance tab cards)
- **06-dashboard-rounding.patch**: performance tab cards
  - unify card corner radius to `Tokens.rounding.large` (what BatteryTank uses)
    across HeroCard, NetworkCard, StorageCard, MemoryCard
  - the matching main-dash radius changes live in 05 because `Dash.qml` already
    belongs to that patch (one file must not be covered by two patches)
- **07-wifi-captive-portal.patch**: surface captive portal state
  - `services/Nmcli.qml`: OWN portal probe a la Firefox (curl
    `detectportal.firefox.com/success.txt`, expect body "success"; a redirect
    or tampered body means portal, timeout means no internet). Probes on
    connect + burst (3s/8s/15s/30s/60s) + every 15s until the network is
    confirmed good, then every 60s. Exposes `Nmcli.connectivity`,
    `Nmcli.captivePortal` and `Nmcli.portalUrl` (captured from the portal's
    302 redirect). NM `Connectivity is now` monitor lines are also parsed,
    but NOT relied on: NM's checker was found disabled at runtime
    (`ConnectivityCheckEnabled=false`) while a UniFi portal was live
  - `modules/bar/popouts/Network.qml`: "Sign-in required" notice at the top of
    the network popout with an "Open login page" button that opens the
    captured `portalUrl` (falls back to the plain-http probe URL)
  - wifi popup auth coverage: enterprise (802.1X) networks get a username +
    password dialog (PEAP/MSCHAPv2 defaults via `Nmcli.connectEnterprise`,
    other EAP methods stay CLI territory), and a "Join hidden network" button
    (SSID + optional password via `Nmcli.connectHidden`). Covers
    `WirelessPassword.qml` (three dialog modes) + the popout list + service
  - wifi popup UX: per-auth-type icons (globe = seen captive portal,
    remembered in `~/.local/state/caelestia/portal-ssids.json`; badge = 802.1X;
    lock = PSK), whole row is the click target, current IPv4 always shown next
    to the network count, and a `page_info` details view (same popout) listing
    every addressed interface incl. WireGuard/Tailscale with IPv4/IPv6/GW/DNS/
    Sec/MAC/Drv/MTU rows via `Nmcli.getAllDeviceDetails`
  - `utils/Browser.qml` (new): `Browser.use(url)` singleton. Reuses a browser
    that already has a window (new tab + focuswindow, xdg default browser
    first, then zen/firefox/chrome/chromium/brave/vivaldi/librewolf),
    otherwise launches the first installed one in that order. The focus
    dispatch is delayed 400ms because the closing popout refocuses the window
    under the cursor and would undo it
  - `modules/bar/components/StatusIcons.qml`: bar wifi icon becomes a red
    `captive_portal` glyph while a portal is detected, and turns red when
    connected without internet (connectivity limited/none)
  - toast "Sign-in required" fires the moment NM flags a portal; the popout
    banner also covers the connected-but-no-internet case
  - requires NM connectivity checking (enabled by default on Arch via
    `/usr/lib/NetworkManager/conf.d/20-connectivity.conf`)
  - related system fix (2026-07-05, not part of the patch): removed
    `/etc/NetworkManager/conf.d/10-dns-servers.conf` which forced global DNS
    `1.1.1.1,8.8.8.8` on every network; that both breaks captive portals that
    block outside DNS and prevents NM from ever reporting `portal`
- **08-xhisper-overlay.patch**: `modules/xhisper/Xhisper.qml` (new) + `shell.qml`
  - floating recording/transcribing pill anchored to the active Hyprland window,
    driven by the `xhisper` IPC (`caelestia shell xhisper set recording|transcribing|hidden`);
    mic level read ~20 Hz via `~/.local/bin/xhisper-volume`
- **09-claude-notifs.patch**: `modules/notifications/Notification.qml`
  - Claude Code notifications render the logo square and uncropped
  - notifications from app "xhisper to Claude" render as two-sided chat bubbles
    (You = mic avatar, Claude = logo avatar)
- **10-osd-output-toggle.patch**: `modules/osd/Content.qml`
  - headphones/speakers flip button in the volume OSD; sink match strings
    "Scarlett" and "Built-in" are banditbox hardware
- **11-app-output-routing.patch**: `services/Audio.qml` + nexus `AppVolumes.qml`
  - per-app output device dropdown, moves streams via `pw-metadata target.node`
- **12-behavior-tweaks.patch**: `assets/wrap_term_launch.sh` + `services/Brightness.qml`
  - terminals keep their own themes (sequences.txt push disabled)
  - monitor `HDMI-A-1` brightness via `~/.local/bin/shader-brightness` instead of ddcutil

Banditbox divergences from kangaeru's series: 01 also swaps the editor to
`satty -f` and adds a Scribble action; 04 also carries the `bar togglePersistent`
IPC in `Shortcuts.qml` (one-file-one-patch rule); 05 keeps the dashboard media
image (only implicitHeight + rounding retained from the Media.qml hunk).

## Dropped on the 1.x → 2.x migration

- **favourite apps**: now native in caelestia-shell 2.x. Configure via
  `~/.config/caelestia/shell.json` under `launcher.favouriteApps` instead of
  patching QML/C++.

## Origin

Ported 2026-07-06 from kangaeru's patch series (which itself originated from
kangaeru's old manual v1.4.1 checkout) onto the caelestia-shell 2.1.0 package.
Banditbox patches 08-12 were added from the retired git fork, archived at
`caelestia.fork-20260706`.
