# Add Full Declarative Dank Material Shell Configuration

## Overview
- Expand the minimal DMS config in `modules/home/desktop/default.nix` to a full declarative configuration
- Ensures identical DMS settings on both hosts (feywild and maple) via shared home-manager module
- Covers theming, panel, animations, notifications, power, lock screen, fonts, and launcher

## Context (from discovery)
- DMS home-manager module already imported via `inputs.dms.homeModules.dank-material-shell`
- Current config is minimal: `enable = true` + systemd settings (lines 23-29 of `modules/home/desktop/default.nix`)
- Both hosts import `modules/home/` — no wiring changes needed
- `flake.nix` already has the `dms` input configured
- DMS exposes feature toggles (`enableDynamicTheming`, etc.) and a `settings` attrset written to `~/.config/DankMaterialShell/settings.json`

## Development Approach
- **testing approach**: NixOS config has no unit tests — validation is via `nix flake check` (evaluation) + `nixos-rebuild build` (full build)
- Single file modification — expand the existing `programs.dank-material-shell` block
- Feature toggles go at the module level; settings go inside the `settings` attrset
- No host-specific overrides needed
- Option names must be verified against the DMS module source before use

## Progress Tracking
- Mark completed items with `[x]` immediately when done
- Add newly discovered tasks with + prefix
- Document issues/blockers with warning prefix
- Update plan if implementation deviates from original scope

## Implementation Steps

### Task 0: Verify DMS module option names

**Files:**
- Reference: DMS home-manager module source (nix store or git clone)

- [x] Inspect the DMS home-manager module definition (e.g., `options.nix` and `home.nix` from the flake input) to confirm all feature toggle names (`enableDynamicTheming`, `enableSystemMonitoring`, etc.) — all 6 confirmed correct
- [x] Confirm the `settings` attrset is freeform JSON (passed through to `settings.json`) or has typed options — confirmed freeform JSON (`pkgs.formats.json`)
- [x] Verify how enum values are handled (integer indices vs string names for `animationSpeed`, `notificationPopupPosition`, etc.) — integer indices confirmed
- [x] Document any corrections to option names in this plan — suspend behavior uses integers (0=Suspend, 1=Hibernate, 2=SuspendThenHibernate), not strings. Position enum: 0=Top, 1=Bottom, 2=Left, 3=Right, 4=TopCenter, 5=BottomCenter, 6=LeftCenter, 7=RightCenter. Notification popup position enum needs runtime verification for BottomRight.

### Task 1: Add DMS feature toggles

**Files:**
- Modify: `modules/home/desktop/default.nix`

- [x] Add `enableDynamicTheming = true` (matugen wallpaper-based color generation)
- [x] Add `enableSystemMonitoring = true` (CPU, RAM, GPU, temp widgets)
- [x] Add `enableAudioWavelength = true` (audio visualization)
- [x] Add `enableVPN = true`
- [x] Add `enableCalendarEvents = true`
- [x] Add `enableClipboardPaste = true`
- [x] Run `nix flake check` to validate syntax
- [x] Run `nixos-rebuild build --flake .#maple` — build fails due to unrelated claude-code 404 (pre-existing); DMS evaluation passes

### Task 2: Add theming and visual settings

**Files:**
- Modify: `modules/home/desktop/default.nix`

- [x] Add `settings` attrset to `programs.dank-material-shell`
- [x] Configure dynamic theming: `matugenScheme = "scheme-tonal-spot"`
- [x] Set transparency and visual defaults: `cornerRadius = 12`, `popupTransparency = 1.0`, `enableRippleEffects = true`
- [x] Set animation: `animationSpeed = 1` (Short), `syncComponentAnimationSpeeds = true`
- [x] Run `nix flake check`

### Task 3: Add panel/bar widget settings

**Files:**
- Modify: `modules/home/desktop/default.nix`

- [x] Enable all panel widgets: `showLauncherButton`, `showWorkspaceSwitcher`, `showFocusedWindow`, `showWeather`, `showMusic`, `showClipboard`, `showCpuUsage`, `showMemUsage`, `showCpuTemp`, `showGpuTemp`, `showSystemTray`, `showClock`, `showNotificationButton`, `showBattery`, `showControlCenterButton`, `showCapsLockIndicator` — all `true`
- [x] Configure clock: `use24HourClock = false`, `showSeconds = false`, `padHours12Hour = false`
- [x] Disable dock: `showDock = false`
- [x] Run `nix flake check`
- [x] Run `nixos-rebuild build --flake .#maple` — same pre-existing claude-code 404; DMS evaluation passes

### Task 4: Add notification settings

**Files:**
- Modify: `modules/home/desktop/default.nix`

- [x] Set notification position: `notificationPopupPosition = 3` (Position.Right = bottom-right, verified from QML source)
- [x] Enable compact mode: `notificationCompactMode = true`
- [x] Enable history: `notificationHistoryEnabled = true`
- [x] Run `nix flake check`

### Task 5: Add power management and lock settings

**Files:**
- Modify: `modules/home/desktop/default.nix`

- [x] Set suspend behavior: `acSuspendBehavior = 0`, `batterySuspendBehavior = 0` (0=Suspend, integer enum)
- [x] Enable lock before suspend: `lockBeforeSuspend = true`
- [x] Enable night mode: `nightModeEnabled = true`
- [x] Run `nix flake check`

### Task 6: Add lock screen settings

**Files:**
- Modify: `modules/home/desktop/default.nix`

- [x] Enable all lock screen elements: `lockScreenShowTime = true`, `lockScreenShowDate = true`, `lockScreenShowProfileImage = true`, `lockScreenShowMediaPlayer = true`, `lockScreenShowPowerActions = true`, `lockScreenShowSystemIcons = true`, `lockScreenShowPasswordField = true`
- [x] Run `nix flake check`

### Task 7: Add font and launcher settings

**Files:**
- Modify: `modules/home/desktop/default.nix`

- [x] Set fonts: `fontFamily = "Berkeley Mono"`, `monoFontFamily = "PragmataPro Mono Liga"`, `fontScale = 1.0`
- [x] Set launcher: `appLauncherViewMode = "list"`, `sortAppsAlphabetically = true`, `launcherLogoMode = "nix"`
- [x] Run `nix flake check`

### Task 8: Final validation

**Files:**
- Modify: `modules/home/desktop/default.nix` (if fixes needed)

- [x] Run `nix flake check` — passed
- [x] Run `nixos-rebuild build` — pre-existing claude-code 404 prevents full build; DMS config evaluates successfully on both hosts
- [x] Review final file for correctness and completeness
- [x] Verify all requirements from Overview are implemented
- [ ] Update CLAUDE.md if needed (e.g., note DMS is fully configured)
- [ ] Move this plan to `docs/plans/completed/`

## Technical Details

**DMS settings mapping:**
- Module-level feature toggles: `enableDynamicTheming`, `enableSystemMonitoring`, `enableAudioWavelength`, `enableVPN`, `enableCalendarEvents`, `enableClipboardPaste`
- `settings` attrset: written as JSON to `~/.config/DankMaterialShell/settings.json`
- Setting names match QML property names from `SettingsData.qml`
- Enum values (e.g., `animationSpeed`, `notificationPopupPosition`) use integer indices matching QML enum order

**Position enum (from QML SettingsData.qml):**
- 0 = Top, 1 = Bottom, 2 = Left, 3 = Right, 4 = TopCenter, 5 = BottomCenter, 6 = LeftCenter, 7 = RightCenter
- Note: `notificationPopupPosition` may use a different popup-specific enum — verify at runtime

**Animation speed enum:**
- 0 = None, 1 = Short, 2 = Medium, 3 = Long, 4 = Custom

**Suspend behavior enum:**
- 0 = Suspend, 1 = Hibernate, 2 = SuspendThenHibernate

**Settings type:** freeform JSON (`pkgs.formats.json`) — no Nix-level type checking; values are written verbatim to `~/.config/DankMaterialShell/settings.json`

## Post-Completion

**Manual verification:**
- Apply config on one host: `sudo nixos-rebuild switch --flake .#<hostname>`
- Verify DMS launches with correct theme (dynamic colors from wallpaper)
- Verify all panel widgets are visible and functional
- Verify 12h clock format without padding
- Verify notifications appear bottom-right in compact mode
- Verify lock screen shows all elements
- Verify fonts render correctly (Berkeley Mono UI, PragmataPro Mono Liga mono)
- Verify launcher opens in list view with alphabetical sorting and Nix logo
- Apply on second host and confirm identical behavior
