{
  inputs = {
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.inputs.flake-utils.follows = "flake-utils";
    cargo2nix.url = "github:cargo2nix/cargo2nix/release-0.11.0";
    cargo2nix.inputs.rust-overlay.follows = "rust-overlay";
    flake-utils.follows = "cargo2nix/flake-utils";
    nixpkgs.follows = "cargo2nix/nixpkgs";
  };

  outputs = { nixpkgs, flake-utils, cargo2nix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        rustVersion = "latest";
        rustChannel = "nightly";
        packageFun = import ./Cargo.nix;

        pkgs = import nixpkgs {
          inherit system;
          overlays = [ cargo2nix.overlays.default ];
        };

        rustpkgs = pkgs.rustBuilder.makePackageSet {
          inherit rustVersion rustChannel packageFun;
          extraRustComponents = [ "clippy" ];
        };

      in {
        devShells.default =
          rustpkgs.workspaceShell { packages = [ pkgs.just ]; };
        packages.default = rustpkgs.workspace.breakout { };
      });
}
