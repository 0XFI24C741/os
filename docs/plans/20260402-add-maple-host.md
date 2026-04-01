# Add Second NixOS Host "maple"

## Overview
- Add a new host `maple` to the flake for the current desktop machine
- Refactor shared boot config so LUKS-specific settings live with the host that needs them
- Both hosts (`feywild` and `maple`) share identical system and home-manager modules

## Context (from discovery)
- **Files involved**: `flake.nix`, `hosts/feywild/default.nix`, `modules/system/nixos/boot.nix`
- **New files**: `hosts/maple/default.nix`, `hosts/maple/hardware-configuration.nix`
- **Hardware source**: `/etc/nixos/hardware-configuration.nix` on current machine
- **Key difference**: feywild uses LUKS encryption + swap; maple uses plain ext4, no swap
- **Pattern**: each host gets its own dir under `hosts/` with `default.nix` + `hardware-configuration.nix`

## Development Approach
- NixOS configs have no unit test framework; validation is via `nix flake check` (evaluation) and `nixos-rebuild build` (build correctness)
- Run `nix flake check` after each task before moving to the next
- Complete each task fully before moving to the next

## Acceptance Criteria
- `nix flake check` passes with both hosts
- `nixos-rebuild build --flake .#maple` succeeds
- Existing `feywild` configuration remains unchanged and builds successfully

## Progress Tracking
- Mark completed items with `[x]` immediately when done
- Add newly discovered tasks with + prefix
- Document issues/blockers with warning prefix

## Implementation Steps

### Task 1: Move LUKS config from shared module to feywild host

**Files:**
- Modify: `modules/system/nixos/boot.nix`
- Modify: `hosts/feywild/default.nix`

- [ ] Remove LUKS swap unlock line (lines 10-11) from `modules/system/nixos/boot.nix`
- [ ] Add the LUKS swap unlock config to `hosts/feywild/default.nix`
- [ ] Run `nix flake check` — feywild must still evaluate cleanly

### Task 2: Create maple host directory

**Files:**
- Create: `hosts/maple/hardware-configuration.nix`
- Create: `hosts/maple/default.nix`

- [ ] Copy `/etc/nixos/hardware-configuration.nix` to `hosts/maple/hardware-configuration.nix`
- [ ] Create `hosts/maple/default.nix` mirroring feywild structure with hostname "maple", no LUKS config
- [ ] Run `nix flake check` — maple must evaluate cleanly

### Task 3: Register maple in flake.nix

**Files:**
- Modify: `flake.nix`

- [ ] Add `maple` as a `let` binding alongside `feywild` (same style: `nixpkgs.lib.nixosSystem`, shared `system` and `args` variables), then inherit into `nixosConfigurations`
- [ ] Run `nix flake check` — both hosts must evaluate cleanly

### Task 4: Validate

- [ ] Run `nix flake check` to verify both configurations evaluate cleanly
- [ ] Dry-run build: `sudo nixos-rebuild build --flake .#maple`

### Task 5: Update CLAUDE.md

**Files:**
- Modify: `CLAUDE.md`

- [ ] Update architecture description ("single-host" -> two hosts)
- [ ] Add `maple` rebuild commands alongside `feywild` commands
- [ ] Update module tree to show both hosts

## Technical Details

**hosts/maple/default.nix** structure:
- Imports: `./hardware-configuration.nix`, `../../modules/system`, `home-manager` module
- Sets `networking.hostName = "maple"`
- Configures home-manager for user `fractal` (same as feywild)
- Passes same `extraSpecialArgs` (inputs, username, realname)

**flake.nix** change:
- Add `maple` using same pattern as `feywild` — `nixpkgs.lib.nixosSystem` with `modules = [ ./hosts/maple ]`

## Post-Completion

**Rebuild on current machine:**
- `sudo nixos-rebuild switch --flake .#maple`
- This will change the hostname from `feywild` to `maple`

**Switch to maple on current machine:**
- `sudo nixos-rebuild switch --flake .#maple`
- This will change the hostname from `feywild` to `maple`
