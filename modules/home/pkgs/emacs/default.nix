{ pkgs, ... }:
let
  emacs = (pkgs.emacsPackagesFor pkgs.emacs-pgtk).emacsWithPackages (epkgs: [
    epkgs.treesit-grammars.with-all-grammars
  ]);
in
{
  home.packages = with pkgs; [
    emacs
    # rust-analyzer is provided by rustup (modules/home/pkgs/rust/).
    # Note: eglot will silently fail for Rust files if no rustup toolchain
    # is installed. Run `rustup default stable` after first login.
    lldb
    (hunspell.withDicts (dicts: with dicts; [ en_US ]))
  ];

  xdg.configFile = {
    "emacs/early-init.el".source = ./early-init.el;
    "emacs/init.el".source = ./init.el;
    # Symlinks lisp/ into the Nix store, making it read-only at runtime.
    # This is intentional — config is managed declaratively via Nix.
    "emacs/lisp".source = ./lisp;
  };
}
