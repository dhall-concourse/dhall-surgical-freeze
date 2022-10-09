{
  description = "Dev Setup";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {nixpkgs, flake-utils, ...}:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        # Avoids unnecessary recompiles
        filteredSource = pkgs.lib.cleanSourceWith {
          src = ./.;
          filter = path: type:
            let baseName = baseNameOf (toString path);
            in pkgs.lib.cleanSourceFilter path type && !(
              baseName == "flake.nix" ||
              baseName == "flake.lock" ||
              baseName == "dist-newstyle" ||
              builtins.match "^cabal\.project\..*$" baseName != null ||
              baseName == "hls.sh" ||
              baseName == ".envrc" ||
              baseName == "hie.yaml" ||
              baseName == ".hlint.yaml" ||
              baseName == ".hspec" ||
              baseName == "ci"
            );
        };
        ghcOverrides = hself: hsuper: rec {
          dhall-surgical-freeze = pkgs.haskell.lib.overrideSrc (hsuper.callPackage ./default.nix {}) {
            src = filteredSource;
          };
        };
        ghc924Pkgs = pkgs.haskell.packages.ghc924.override {
          overrides = ghcOverrides;
        };
        ghc902Pkgs = pkgs.haskell.packages.ghc902.override {
          overrides = ghcOverrides;
        };
        ghc8107Pkgs = pkgs.haskell.packages.ghc8107.override {
          overrides = ghcOverrides;
        };
        ghc884Pkgs = pkgs.haskell.packages.ghc884.override {
          overrides = ghcOverrides;
        };
      in rec {
        packages = rec {
          dev-env = ghc902Pkgs.shellFor {
            packages = p: [p.dhall-surgical-freeze];
            withHoogle = true;
            buildInputs = [
              pkgs.haskellPackages.cabal-install
              (pkgs.haskell-language-server.override {supportedGhcVersions = ["902"];})
              pkgs.haskellPackages.implicit-hie
              pkgs.cabal2nix

              # For cabal
              pkgs.pkg-config
              pkgs.binutils

              # For CI
              pkgs.jq
              pkgs.dhall
              pkgs.dhall-json
              pkgs.fly
            ];
          };
        };
        defaultPackage = packages.dev-env;
    });
}
