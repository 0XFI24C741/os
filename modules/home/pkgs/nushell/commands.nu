export def flake-ref [] { $".#(sys host | get hostname)" }

export def flake-bump [] {
    git add flake.lock
    if $env.LAST_EXIT_CODE == 0 {
        git commit -m "flake bump"
    }
}

export def --wrapped rebuild [...rest] {
    sudo nixos-rebuild switch --flake (flake-ref) ...$rest
}

export def --wrapped rebuild-build [...rest] {
    nixos-rebuild build --flake (flake-ref) ...$rest
}

export def --wrapped nd [...rest] {
    nix develop ...$rest -c nu
}

export def --wrapped nsh [...rest] {
    nix-shell ...$rest --command nu
}
