# Starship Prompt (Replace Default Bash PS1)

## Overview

Replace the default bash prompt (`[fractal@maple]$`) with [Starship](https://starship.rs) — a fast, cross-shell prompt. The configuration will be minimal (directory, git branch/status, command duration, prompt character) and use nerd-font icons the user already has installed. Colors will use ANSI palette names only so that the DankMaterialShell (DMS) matugen-generated adaptive theme drives the appearance — no hex codes anywhere.

**Problem solved:** the default bash prompt is information-poor (no git info, no exit status, no command duration) and visually bland. Starship adds contextual info without manual PS1 escape-code maintenance.

**Integration:** new dedicated home-manager module at `modules/home/pkgs/starship/default.nix`, wired into the existing explicit-imports list in `modules/home/pkgs/default.nix`.

## Context (from discovery)

**Files involved:**
- `modules/home/pkgs/default.nix` — explicit imports list (`./alacritty`, `./bash`); must add `./starship`
- `modules/home/pkgs/starship/default.nix` — NEW module file
- `modules/home/pkgs/bash/default.nix` — unchanged (aliases only, no PS1 currently)
- `modules/system/desktop/default.nix:50` — already provides `nerd-fonts.ubuntu-mono` (icons will render)

**Related patterns:** sibling module `modules/home/pkgs/bash/default.nix` uses `{ ... }:` header and `programs.bash = { ... };` style — same pattern applies here with `programs.starship`.

**Dependencies:** `programs.starship` is a stock home-manager option; no flake input changes needed.

## Development Approach

- **Testing approach:** N/A in the traditional unit-test sense — this is Nix configuration, not application code. Verification is done via `nix flake check` (evaluation/type check) and `nixos-rebuild build` (full build) as substitutes for unit tests, plus a post-activation manual sanity check in a new terminal.
- Complete each task fully before moving to the next
- Make small, focused changes
- **CRITICAL: every task MUST include verification** — `nix flake check` after file changes, full build before activation
- **CRITICAL: all verifications must pass before starting the next task**
- **CRITICAL: update this plan file when scope changes during implementation**
- Maintain backward compatibility (bash aliases untouched)
- Remember: Nix flakes only evaluate git-tracked files → `git add` new files before any check/build

## Testing Strategy

- **Evaluation tests:** `nix flake check` — catches syntax errors, missing attributes, and broken module arguments. Note: this evaluates **both** `nixosConfigurations.maple` and `nixosConfigurations.feywild`, so shared-module changes are verified against both hosts in one command.
- **Build tests:** `nixos-rebuild build --flake .#maple` (no sudo per user preference) — catches home-manager option mismatches and builds the full system closure without activating
- **Manual sanity check:** after `nixos-rebuild switch`, open a new terminal and visually confirm:
  - Prompt displays directory, git info (when in a git repo), prompt character
  - Icons render correctly (no `□` boxes)
  - Colors inherit from DMS theme (check by comparing against other DMS-themed surfaces)
  - Exit status changes `❯` color (run `false` to see red)

## Progress Tracking

- Mark completed items with `[x]` immediately when done
- Add newly discovered tasks with ➕ prefix
- Document issues/blockers with ⚠️ prefix
- Update plan if implementation deviates from original scope
- Keep plan in sync with actual work done

## What Goes Where

- **Implementation Steps** (`[ ]` checkboxes): Nix file edits, `git add`, `nix flake check`, `nixos-rebuild build`
- **Post-Completion** (no checkboxes): `sudo nixos-rebuild switch` (requires sudo + user confirmation) and manual terminal sanity check

## Implementation Steps

### Task 1: Create Starship home-manager module

**Files:**
- Create: `modules/home/pkgs/starship/default.nix`

- [ ] create `modules/home/pkgs/starship/default.nix` with `{ ... }:` header (no `lib` needed — using plain string for `format`)
- [ ] enable `programs.starship` with `enableBashIntegration = true;`
- [ ] set minimal `format` as plain string: `"$directory$git_branch$git_status$cmd_duration$line_break$character"`
- [ ] configure nerd-font icons using nested-set style: `directory = { read_only = " 󰌾"; };` and `git_branch = { symbol = " "; };`
- [ ] configure `git_status` symbols (ahead/behind/diverged/untracked/modified/staged) — escape `${count}` as `\${count}` so Nix passes literal `${count}` to Starship; add an inline comment explaining the escape
- [ ] configure `character.success_symbol = "[❯](bold green)"` and `error_symbol = "[❯](bold red)"` — ANSI color names only, NO hex codes (DMS adaptive theme must drive colors)

### Task 2: Wire module into home-manager imports

**Files:**
- Modify: `modules/home/pkgs/default.nix`

- [ ] add `./starship` to the `imports` list in `modules/home/pkgs/default.nix` after `./bash` — final order is alphabetical: `./alacritty`, `./bash`, `./starship`

### Task 3: Stage files and verify evaluation

**Files:**
- (no file edits — verification only)

- [ ] `git add modules/home/pkgs/starship/default.nix modules/home/pkgs/default.nix` (flakes only see git-tracked files)
- [ ] run `nix flake check` (no sudo) — must pass before next task
- [ ] if errors: fix them in Task 1 or 2 and re-stage before re-running

### Task 4: Full build verification

**Files:**
- (no file edits — verification only)

- [ ] run `nixos-rebuild build --flake .#maple` (no sudo) — must pass before activation
- [ ] if build errors: diagnose (usually a typo in Starship option name or Nix syntax) and loop back

### Task 5: Verify acceptance criteria and finalize

- [ ] confirm new file is git-staged: `git status` shows `modules/home/pkgs/starship/default.nix` as new
- [ ] confirm imports list updated: `modules/home/pkgs/default.nix` includes `./starship`
- [ ] confirm `nix flake check` passes with no new warnings attributable to this change
- [ ] confirm `nixos-rebuild build` completes successfully
- [ ] no CLAUDE.md update needed — Starship follows standard home-manager pattern and adds no new conventions
- [ ] move this plan to `docs/plans/completed/` after user confirms the activated prompt looks right in a new terminal

## Technical Details

**Module structure:**
```nix
{ ... }:
{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";

      directory = {
        read_only = " 󰌾";
      };
      git_branch = {
        symbol = " ";
      };
      git_status = {
        # \${...} escapes Nix antiquotation; Starship receives literal ${...}
        ahead  = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        untracked = "?";
        modified  = "!";
        staged    = "+";
      };
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol   = "[❯](bold red)";
      };
    };
  };
}
```

**Key technical points:**
- No `lib` needed — `format` is a plain string concatenation, so the module header is just `{ ... }:`.
- `\${count}` / `\${ahead_count}` / `\${behind_count}` — the backslash escapes Nix's interpolation so the literal `${count}` reaches Starship, which does its own template substitution. Inline comment in the module file explains this to future readers.
- Nested-set style is used consistently for `directory`, `git_branch`, `git_status`, and `character` rather than mixing dotted-attr and set styles.
- `add_newline` is omitted because Starship's default is already `true`.
- `programs.starship` option is provided by home-manager directly — no need to add `starship` to `home.packages`. Home-manager installs the binary and writes `~/.config/starship.toml` from `settings`.
- `enableBashIntegration = true;` injects `eval "$(starship init bash)"` into `.bashrc`. Bash's default `PS1` is overridden automatically at shell init.
- Feywild host gets the same prompt — this module applies to both hosts since it's under shared `modules/home/`.

**Why ANSI names, not hex:**
DMS uses [matugen](https://github.com/InioX/matugen) to generate an ANSI color palette from the wallpaper. Terminal emulators that honor this palette (alacritty with DMS integration) remap colors like `green`, `red`, `blue` to matugen-chosen values. If Starship emitted hex codes, those would bypass the palette and break adaptive theming. Sticking to ANSI names means the prompt automatically re-themes whenever DMS updates the wallpaper palette.

## Post-Completion

*Items requiring manual intervention — no checkboxes*

**Activation (requires sudo):**
- User runs: `sudo nixos-rebuild switch --flake .#maple`
- Per user memory (`feedback_avoid_sudo.md`): this is one of the few commands where sudo is actually needed. `build` and `flake check` stay sudo-free.

**Manual verification in a new terminal:**
- Open a fresh terminal (the currently-open one still has old bash PS1 — Starship loads on shell start)
- Expected: prompt shows `~/Developer/os  master !` (or similar) with colored `❯` below
- Run `false` and check that the next `❯` turns red
- Run `cd /tmp` and check that git info disappears
- Run `cd ~/Developer/os` and check that git info reappears
- Verify icons render (no `□`) — `nerd-fonts.ubuntu-mono` should handle all symbols used

**If icons don't render:**
- Terminal emulator must be configured to use the nerd font. Alacritty config should already point to a nerd-font-enabled family. If not, that's a separate alacritty plan item — not in scope here.

**Feywild host:**
- Same `sudo nixos-rebuild switch --flake .#feywild` on the laptop when user next uses it. No plan changes needed — module is shared.

**Future iterations (out of scope for this plan):**
- Add more Starship modules if the minimal format feels too spartan (e.g. `$hostname` when SSH'd, `$nix_shell` indicator)
- Pick a preset (`tokyo-night`, `pastel-powerline`, etc.) if stock minimal grows tiresome
- Port to zsh/fish if shell migration happens
