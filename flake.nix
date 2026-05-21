{
  description = "Personal Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      ...
    }@inputs:
    let
      args = { inherit inputs; };
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      feywild = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./hosts/feywild ];
        specialArgs = args;
      };

      maple = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./hosts/maple ];
        specialArgs = args;
      };
    in
    {
      nixosConfigurations = {
        inherit feywild maple;
      };

      checks.${system} = {
        feywild = feywild.config.system.build.toplevel;
        maple = maple.config.system.build.toplevel;
      };

      formatter.${system} = pkgs.writeShellApplication {
        name = "nixfmt-tree";
        runtimeInputs = [
          pkgs.findutils
          pkgs.git
          pkgs.nixfmt
        ];
        text = ''
          if [ "$#" -gt 0 ]; then
            exec nixfmt "$@"
          fi

          git ls-files '*.nix' ':(exclude)hosts/*/hardware-configuration.nix' -z \
            | xargs -0 --no-run-if-empty nixfmt
        '';
      };
    };

}
