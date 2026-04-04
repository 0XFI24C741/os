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

- [ ] Inspect the DMS home-manager module definition (e.g., `options.nix` and `home.nix` from the flake input) to confirm all feature toggle names (`enableDynamicTheming`, `enableSystemMonitoring`, etc.)
- [ ] Confirm the `settings` attrset is freeform JSON (passed through to `settings.json`) or has typed options
- [ ] Verify how enum values are handled (integer indices vs string names for `animationSpeed`, `notificationPopupPosition`, etc.)
- [ ] Document any corrections to option names in this plan

### Task 1: Add DMS feature toggles

**Files:**
- Modify: `modules/home/desktop/default.nix`

- [ ] Add `enableDynamicTheming = true` (matugen wallpaper-based color generation)
- [ ] Add `enableSystemMonitoring = true` (CPU, RAM, GPU, temp widgets)
- [ ] Add `enableAudioWavelength = true` (audio visualization)
- [ ] Add `enableVPN = true`
- [ ] Add `enableCalendarEvents = true`
- [ ] Add `enableClipboardPaste = true`
- [ ] Run `nix flake check` to validate syntax
- [ ] Run `nixos-rebuild build --flake .#maple` to catch build-time errors early

### Task 2: Add theming and visual settings

**Files:**
- Modify: `modules/home/desktop/default.nix`

- [ ] Add `settings` attrset to `programs.dank-material-shell`
- [ ] Configure dynamic theming: `matugenScheme = "scheme-tonal-spot"`
- [ ] Set transparency and visual defaults: `cornerRadius = 12`, `popupTransparency = 1.0`, `enableRippleEffects = true`
- [ ] Set animation: `animationSpeed = 1` (Short), `syncComponentAnimationSpeeds = true`
- [ ] Run `nix flake check`

### Task 3: Add panel/bar widget settings

**Files:**
- Modify: `modules/home/desktop/default.nix`

- [ ] Enable all panel widgets: `showLauncherButton`, `showWorkspaceSwitcher`, `showFocusedWindow`, `showWeather`, `showMusic`, `showClipboard`, `showCpuUsage`, `showMemUsage`, `showCpuTemp`, `showGpuTemp`, `showSystemTray`, `showClock`, `showNotificationButton`, `showBattery`, `showControlCenterButton`, `showCapsLockIndicator` — all `true`
- [ ] Configure clock: `use24HourClock = false`, `showSeconds = false`, `padHours12Hour = false`
- [ ] Disable dock: `showDock = false`
- [ ] Run `nix flake check`
- [ ] Run `nixos-rebuild build --flake .#maple` (largest settings batch — verify build)

### Task 4: Add notification settings

**Files:**
- Modify: `modules/home/desktop/default.nix`

- [ ] Set notification position: `notificationPopupPosition = 5` (BottomRight — verify enum value)
- [ ] Enable compact mode: `notificationCompactMode = true`
- [ ] Enable history: `notificationHistoryEnabled = true`
- [ ] Run `nix flake check`

### Task 5: Add power management and lock settings

**Files:**
- Modify: `modules/home/desktop/default.nix`

- [ ] Set suspend behavior: `acSuspendBehavior = "Suspend"`, `batterySuspendBehavior = "Suspend"`
- [ ] Enable lock before suspend: `lockBeforeSuspend = true`
- [ ] Enable night mode: `nightModeEnabled = true`
- [ ] Run `nix flake check`

### Task 6: Add lock screen settings

**Files:**
- Modify: `modules/home/desktop/default.nix`

- [ ] Enable all lock screen elements: `lockScreenShowTime = true`, `lockScreenShowDate = true`, `lockScreenShowProfileImage = true`, `lockScreenShowMediaPlayer = true`, `lockScreenShowPowerActions = true`, `lockScreenShowSystemIcons = true`, `lockScreenShowPasswordField = true`
- [ ] Run `nix flake check`

### Task 7: Add font and launcher settings

**Files:**
- Modify: `modules/home/desktop/default.nix`

- [ ] Set fonts: `fontFamily = "Berkeley Mono"`, `monoFontFamily = "PragmataPro Mono Liga"`, `fontScale = 1.0`
- [ ] Set launcher: `appLauncherViewMode = "list"`, `sortAppsAlphabetically = true`, `launcherLogoMode = "nix"`
- [ ] Run `nix flake check`

### Task 8: Final validation

**Files:**
- Modify: `modules/home/desktop/default.nix` (if fixes needed)

- [ ] Run `nix flake check` — must pass
- [ ] Run `sudo nixos-rebuild build --flake .#maple` or `sudo nixos-rebuild build --flake .#feywild` (dry build)
- [ ] Review final file for correctness and completeness
- [ ] Verify all requirements from Overview are implemented
- [ ] Update CLAUDE.md if needed (e.g., note DMS is fully configured)
- [ ] Move this plan to `docs/plans/completed/`

## Technical Details

**DMS settings mapping:**
- Module-level feature toggles: `enableDynamicTheming`, `enableSystemMonitoring`, `enableAudioWavelength`, `enableVPN`, `enableCalendarEvents`, `enableClipboardPaste`
- `settings` attrset: written as JSON to `~/.config/DankMaterialShell/settings.json`
- Setting names match QML property names from `SettingsData.qml`
- Enum values (e.g., `animationSpeed`, `notificationPopupPosition`) use integer indices matching QML enum order

**Notification position enum (from QML):**
- 0 = Top, 1 = Bottom, 2 = TopLeft, 3 = TopRight, 4 = BottomLeft, 5 = BottomRight

**Animation speed enum:**
- 0 = None, 1 = Short, 2 = Medium, 3 = Long, 4 = Custom

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
