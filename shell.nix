{
  pkgs ? import <nixpkgs> { },
}:
let
  overrides = (builtins.fromTOML (builtins.readFile ./rust-toolchain.toml));
in
pkgs.callPackage (
  {
    stdenv,
    mkShell,
    rustc,
    cargo,
    rustPlatform,
    rustfmt,
    clippy,
    rust-analyzer,
  }:
  mkShell {
    strictDeps = true;
    nativeBuildInputs = [
      rustc
      cargo
      rustfmt
      clippy
      rust-analyzer
    ];
    # libraries here
    buildInputs = [
    ];
    RUSTC_VERSION = overrides.toolchain.channel;
    RUST_SRC_PATH = "${rustPlatform.rustLibSrc}";
    # https://github.com/rust-lang/rust-bindgen#environment-variables
    shellHook = ''
      export PATH="''${CARGO_HOME:-~/.cargo}/bin":"$PATH"
      export PATH="''${RUSTUP_HOME:-~/.rustup}/toolchains/$RUSTC_VERSION-${stdenv.hostPlatform.rust.rustcTarget}/bin":"$PATH"
    '';
  }
) { }
