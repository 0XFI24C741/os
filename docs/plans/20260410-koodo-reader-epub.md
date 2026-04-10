# Koodo Reader — EPUB reader with library management

## Overview
- Install [Koodo Reader](https://github.com/koodo-reader/koodo-reader) as the user's primary EPUB reader
- Wire up an XDG MIME-type association so double-clicking `.epub` files opens Koodo Reader
- Chosen during brainstorm for library-management-focused reading (shelves, annotations, progress tracking, reading stats) across epub/pdf/mobi/azw3/cbz
- No Electron wrapping required: `NIXOS_OZONE_WL=1` is already set globally in `modules/system/desktop/default.nix:5`, so Chromium/Electron apps auto-run on Wayland via Ozone
- **Acceptance criteria**: `koodo-reader` launches from the app menu, opens EPUB files, and `.epub` files from a file manager open in Koodo by default

## Context (from discovery)
- **Package**: `pkgs.koodo-reader` in nixpkgs-unstable (which this flake tracks)
- **User-package pattern**: `modules/home/pkgs/default.nix:8` — the `home.packages` list is where user apps like `obsidian`, `discord`, `telegram-desktop` live. Koodo belongs here, not at system level.
- **MIME-association pattern**: `modules/home/desktop/default.nix:126` already defines `xdg.mimeApps.defaultApplications` with a `let`-binding (`firefox`, `slack`) mapped onto MIME types. The file also sets `xdg.configFile."mimeapps.list".force = true` (line 151), which means this declarative list owns the final `mimeapps.list` — no risk of it being silently overwritten by ad-hoc `xdg-mime default` calls.
- **Wayland posture**: `modules/system/desktop/default.nix:5` sets `NIXOS_OZONE_WL = "1"`. Electron apps (like Koodo) inherit this and run natively on Wayland — no `--ozone-platform-hint` wrapping needed. Contrast with `synology-drive` in `modules/home/pkgs/default.nix:25-33` which force-sets `QT_QPA_PLATFORM=xcb` — that wrapper exists because Synology's Qt client breaks on Wayland; Koodo does not need equivalent treatment.
- **IANA MIME type**: `application/epub+zip` is the registered identifier and what `file --mime-type` / `xdg-mime query filetype` report on modern systems.

### Files involved
- `modules/home/pkgs/default.nix` — add `koodo-reader` to `home.packages`
- `modules/home/desktop/default.nix` — extend `defaultApplications` with the EPUB binding

## Development Approach
- **Testing approach**: `nix flake check` for syntax/evaluation, `nixos-rebuild build --flake .#<host>` for full build validation, then `nixos-rebuild switch` and manual verification (this repo has no unit-test framework — it's declarative config)
- Complete each task fully before moving to the next
- Keep changes minimal and focused — this is a ~3-line diff
- No new files to create, so no `git add` dance required (flakes ignore untracked files)

## Testing Strategy
- **Syntax/evaluation**: `nix flake check` after each file is touched
- **Full build**: `nixos-rebuild build --flake .#maple` (or `.#feywild` depending on the host currently in use) to verify the config builds
- **Runtime verification**: `nixos-rebuild switch`, then launch `koodo-reader` from a terminal and the app menu, open an EPUB, confirm the library view renders, and confirm `xdg-mime query default application/epub+zip` returns `koodo-reader.desktop`
- **File-manager verification**: open a file manager, double-click an `.epub`, confirm Koodo launches

## Progress Tracking
- Mark completed items with `[x]` immediately when done
- Add newly discovered tasks with ➕ prefix
- Document issues/blockers with ⚠️ prefix

## Implementation Steps

### Task 1: Add koodo-reader package

**Files:**
- Modify: `modules/home/pkgs/default.nix`

- [x] Verify availability: `nix eval github:NixOS/nixpkgs/nixos-unstable#koodo-reader.version` → `"2.2.4"`
- [x] Add `koodo-reader` to the `home.packages` list in `modules/home/pkgs/default.nix` (grouped next to `obsidian`)
- [x] Run `nix flake check` — passed (only pre-existing upstream quickshell `xorg.libxcb` warning)

### Task 2: Add EPUB MIME-type association

**Files:**
- Modify: `modules/home/desktop/default.nix`

- [x] In the `defaultApplications = let … in { … }` block at `modules/home/desktop/default.nix:128`, added `koodo = "koodo-reader.desktop";` to the `let` bindings (alongside `firefox` and `slack`)
- [x] Added `"application/epub+zip" = koodo;` to the attribute set
- [x] Ran `nix flake check` — passed

### Task 3: Build and activate

- [x] Ran `nixos-rebuild build --flake .#maple` — succeeded; `koodo-reader-2.2.4` fetched from cache.nixos.org, `mimeapps.list.drv` rebuilt cleanly
- [x] Confirmed the `.desktop` filename is `koodo-reader.desktop` by inspecting `/nix/store/cv1k0r6wspzx99vqdlalwrygjikxc1ii-koodo-reader-2.2.4/share/applications/` — no contingency needed
- [x] Verified MIME registration in the built `mimeapps.list` derivation source: `application/epub+zip=koodo-reader.desktop` is present
- [ ] ⚠️ `sudo nixos-rebuild switch --flake .#maple` — **deferred by user**; working tree contains unrelated WIP that will be co-activated, user will run switch themselves at their discretion
- [ ] Post-switch: verify `which koodo-reader` on PATH
- [ ] Post-switch: verify `xdg-mime query default application/epub+zip` returns `koodo-reader.desktop`

### Task 4: Runtime verification

- [ ] Launch `koodo-reader` from a terminal — window opens, no crash
- [ ] Launch Koodo Reader from the Niri/DMS app launcher — it appears in the menu
- [ ] Import a test `.epub` into Koodo's library, open it, confirm pagination and typography render correctly
- [ ] In a file manager, locate an `.epub` file, double-click it, confirm Koodo launches and opens that file
- [ ] Confirm Koodo is running natively on Wayland (not XWayland): run `xlsclients` — Koodo should NOT appear in the X client list (if it does, it fell back to XWayland and needs the Ozone wrapper described in Technical Details)

### Task 5: Finalize

- [ ] Move this plan to `docs/plans/completed/`

## Technical Details

**Koodo Reader Nix attribute**: `pkgs.koodo-reader` — Electron-based, bundles its own Chromium.

**Exact diff sketch for `modules/home/pkgs/default.nix`** (add to `home.packages`):
```nix
  home.packages = with pkgs; [
    emacs-pgtk
    zed-editor
    discord
    koodo-reader      # <-- added
    # ...
  ];
```

**Exact diff sketch for `modules/home/desktop/default.nix:128`**:
```nix
defaultApplications =
  let
    firefox = "firefox.desktop";
    slack = "slack.desktop";
    koodo = "koodo-reader.desktop";   # <-- added
  in
  {
    # ... existing entries unchanged ...
    "application/epub+zip" = koodo;   # <-- added
  };
```

**Why `force = true` matters here**: `xdg.configFile."mimeapps.list".force = true` at line 151 means home-manager will overwrite any runtime-edited `mimeapps.list` on activation. This guarantees the declarative binding wins — no surprise if the user or an app had previously called `xdg-mime default something-else.desktop application/epub+zip`.

**Wayland behavior**: Koodo is Electron. With `NIXOS_OZONE_WL=1` exported session-wide, Electron's Ozone platform auto-detects Wayland and runs natively (no XWayland). If for some reason it fails to detect — unlikely, since the flag is the canonical NixOS approach — the fallback is wrapping with `makeWrapper` and `--add-flags "--ozone-platform-hint=auto --enable-features=UseOzonePlatform,WaylandWindowDecorations"`, following the same `symlinkJoin` pattern as the `synology-drive` entry at `modules/home/pkgs/default.nix:25-33`.

**Contingency — wrong .desktop filename**: The plan assumes the desktop file is named `koodo-reader.desktop`, matching the nixpkgs attribute name. nixpkgs conventions make this near-certain, but it can differ (e.g., uppercase, reverse-DNS naming). If Task 3's `find` step turns up a different filename, the fix is one line: update `koodo = "<actual-name>.desktop";` in the let-binding and rebuild. The MIME association will silently no-op (not error) until the filename matches — that's why verification is explicit in Task 3.

**Rollback**: Remove the two additions and rebuild. NixOS generations provide an additional safety net — `sudo nixos-rebuild switch --rollback` reverts to the previous generation without touching the flake source.

## Post-Completion

**Manual verification**:
- Test Koodo Reader against a few different EPUB files (fixed-layout, reflowable, large library) to confirm it handles the formats the user actually cares about
- Confirm library shelves and annotations persist across restarts (Koodo stores state in `~/.config/koodo-reader/` or similar)
- If the user plans to sync libraries across machines, check Koodo's cloud-sync settings (Dropbox/WebDAV/etc.) — this is out of scope for the Nix config but worth knowing

**External considerations**:
- Neither host-specific (`hosts/maple/`, `hosts/feywild/`) config nor the shared `modules/system/` tree needs changes — this is a user-level addition only, so it applies to both hosts via `modules/home/pkgs/` automatically
- No firewall, service, or systemd-unit changes needed
