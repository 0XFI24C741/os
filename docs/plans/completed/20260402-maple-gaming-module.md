# Maple Gaming Module

## Overview
- Create a dedicated `modules/gaming/` module for game-oriented configuration, imported only by the maple (desktop) host
- Consolidates all gaming concerns (Steam, Proton, performance tools, kernel tweaks, controllers) in one place
- Moves existing Steam/Gamescope config out of shared packages module so feywild (laptop) is unaffected

## Context (from brainstorm)
- **Hardware:** AMD Ryzen CPU + AMD Radeon RX 7700 XT/7800 XT (RDNA 3), open-source amdgpu driver stack
- **Use case:** Steam-focused, performance-tuned gaming
- **Structure decision:** Top-level `modules/gaming/` (not under `modules/system/`) to avoid auto-import by both hosts
- Files involved:
  - `modules/gaming/default.nix` (new)
  - `modules/system/packages/default.nix` (remove Steam/Gamescope)
  - `hosts/maple/default.nix` (add import)

## Development Approach
- **Testing approach:** `nix flake check` for evaluation errors, `nixos-rebuild build --flake .#maple` for full build verification
- NixOS config has no unit tests — validation is via Nix evaluation and build
- Complete each task fully before moving to the next

## Progress Tracking
- Mark completed items with `[x]` immediately when done
- Add newly discovered tasks with + prefix
- Document issues/blockers with warning prefix
- Update plan if implementation deviates from original scope

## Implementation Steps

### Task 1: Create gaming module

**Files:**
- Create: `modules/gaming/default.nix`

- [x] Create `modules/gaming/default.nix` with the following sections:
- [x] Steam config: `programs.steam` with `enable`, `remotePlay.openFirewall`, `dedicatedServer.openFirewall`, `extraCompatPackages = [ pkgs.proton-ge-bin ]`
- [x] Gamescope config: `programs.gamescope = { enable = true; capSysNice = true; }`
- [x] Performance tools: `programs.gamemode.enable`, `programs.corectrl.enable`, `mangohud` in `environment.systemPackages`
- [x] Kernel tweaks: `boot.kernel.sysctl."vm.max_map_count" = 2147483642`, `boot.kernelParams = [ "split_lock_detect=off" ]`
- [x] Controller support: `hardware.xpadneo.enable = true`, `hardware.steam-hardware.enable = true`
- [x] `git add modules/gaming/default.nix` (flakes only evaluate git-tracked files)
- [x] Run `nix flake check` to verify syntax

### Task 2: Remove Steam/Gamescope from shared packages module

**Files:**
- Modify: `modules/system/packages/default.nix`

- [x] Remove `programs.gamescope` block
- [x] Remove `programs.steam` block
- [x] Run `nix flake check` to verify no evaluation errors

### Task 3: Wire up maple host

**Files:**
- Modify: `hosts/maple/default.nix`

- [x] Add `../../modules/gaming` to the imports list
- [x] Run `nix flake check` to verify evaluation
- [x] Run `nixos-rebuild build --flake .#maple` to verify full build
- [x] Run `nixos-rebuild build --flake .#feywild` to verify feywild still builds without Steam

### Task 4: Final verification and documentation

- [x] Verify `nix flake check` passes
- [x] Verify both hosts build successfully
- [x] Update CLAUDE.md module tree: add `modules/gaming/` and remove Steam/Gamescope from packages description
- [x] Move this plan to `docs/plans/completed/`

## Technical Details

### Module contents (`modules/gaming/default.nix`)
```nix
{ pkgs, ... }:
{
  # Steam + Proton
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # Performance tools
  programs.gamemode.enable = true;
  programs.corectrl.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud
  ];

  # Kernel tweaks
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;
  };
  boot.kernelParams = [ "split_lock_detect=off" ];

  # Controller support
  hardware.xpadneo.enable = true;
  hardware.steam-hardware.enable = true;
}
```

## Post-Completion

**Manual verification:**
- Apply config with `sudo nixos-rebuild switch --flake .#maple`
- Launch Steam and verify Proton-GE appears in compatibility tool dropdown
- Test MangoHUD overlay with `mangohud %command%` in Steam launch options
- Test GameMode with `gamemoderun %command%` in Steam launch options
- Verify corectrl can see the RX 7700 XT/7800 XT
- Test Xbox controller pairing via Bluetooth (if applicable)
