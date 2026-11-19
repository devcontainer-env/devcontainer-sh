{
  description = "A thin wrapper around the devcontainer CLI: one command, workspace auto-detection";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        # The version lives in the script, where release-please keeps it.
        version = lib.pipe (builtins.readFile ./devcontainer-sh) [
          (lib.splitString "\n")
          (lib.findFirst (lib.hasPrefix "DEVCONTAINER_SH_VERSION=") null)
          (builtins.match "DEVCONTAINER_SH_VERSION=\"([^\"]+)\".*")
          builtins.head
        ];

        devcontainer-sh = pkgs.stdenvNoCC.mkDerivation {
          pname = "devcontainer-sh";
          inherit version;
          src = lib.fileset.toSource {
            root = ./.;
            fileset = lib.fileset.unions [
              ./devcontainer-sh
              ./completions
            ];
          };
          dontBuild = true;
          # The devcontainer CLI and docker are the user's, not wrapped in.
          installPhase = ''
            install -Dm0755 devcontainer-sh $out/bin/devcontainer-sh
            install -Dm0644 -t $out/share/zsh/site-functions \
              completions/_devcontainer-sh completions/_devcontainer
          '';
          meta = {
            description = "A thin wrapper around the devcontainer CLI";
            mainProgram = "devcontainer-sh";
            license = lib.licenses.mit;
          };
        };
      in
      {
        packages.default = devcontainer-sh;

        devShells.default = pkgs.mkShell {
          name = "devcontainer-sh";
          packages = with pkgs; [
            zsh
            bats
            shellcheck
            actionlint
          ];
        };
      }
    );
}
