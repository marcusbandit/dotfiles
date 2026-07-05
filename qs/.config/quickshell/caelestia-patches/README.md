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
- **05-dashboard-declutter.patch**: `modules/dashboard/Dash.qml`
  - remove the small weather widget, the user/avatar card, and the resources
    (performance) column from the main dashboard tab
  - remaining layout is a single row: date/time, calendar, media, plus a
    battery tank (reused from the performance tab) on the right when a laptop
    battery is present
  - related but NOT part of the patch: the Weather tab is hidden natively via
    `dashboard.showWeather: false` in `~/.config/caelestia/shell.json`
- **07-wifi-captive-portal.patch**: surface captive portal state
  - `services/Nmcli.qml`: track NetworkManager connectivity (seed via
    `nmcli -t -f CONNECTIVITY general`, live updates parsed from the existing
    `nmcli monitor` stream), expose `Nmcli.connectivity` + `Nmcli.captivePortal`
  - `modules/bar/popouts/Network.qml`: "Sign-in required" banner at the top of
    the network popout, click opens the login page via
    `xdg-open http://ping.archlinux.org/nm-check.txt` (portal redirect)
  - `modules/bar/components/StatusIcons.qml`: bar wifi icon becomes a red
    `captive_portal` glyph while a portal is detected
  - requires NM connectivity checking (enabled by default on Arch via
    `/usr/lib/NetworkManager/conf.d/20-connectivity.conf`)
  - `dash/Media.qml`: declare an implicitHeight (the card used to be stretched
    by the old two-row grid), drop the bongocat gif and its beat-tracker
    ServiceRef, and use `rounding.large` on the main dash cards (see 06)
- **06-dashboard-rounding.patch**: performance tab cards
  - unify card corner radius to `Tokens.rounding.large` (what BatteryTank uses)
    across HeroCard, NetworkCard, StorageCard, MemoryCard
  - the matching main-dash radius changes live in 05 because `Dash.qml` already
    belongs to that patch (one file must not be covered by two patches)

## Dropped on the 1.x → 2.x migration

- **favourite apps**: now native in caelestia-shell 2.x. Configure via
  `~/.config/caelestia/shell.json` under `launcher.favouriteApps` instead of
  patching QML/C++.

## Origin

Ported 2026-06-08 from the old manual v1.4.1 checkout
(`~/.config/quickshell/caelestia.old-1.4.1-*`) when the package jumped to 2.x and
the old `Caelestia.Internal.CachingImageManager` type was removed.
