{ pkgs ? import <nixpkgs> {} }:

let
  fenix = import "${
  fetchTarball "https://github.com/nix-community/fenix/archive/main.tar.gz"
  }/packages.nix";

  unstable = import (
    fetchTarball
      "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz"
  ) {};
in

pkgs.mkShell {
  shellHook = ''export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${pkgs.lib.makeLibraryPath [ pkgs.udev pkgs.alsaLib ]}"'';

  buildInputs = with pkgs; [
    (
      with fenix;
      combine (
        with default; [
          cargo
          clippy-preview
          latest.rust-src
          rust-analyzer
          rust-std
          rustc
          rustfmt-preview
        ]
      )
    )
    cargo-edit
    cargo-watch
    wasm-pack

    lld
    clang

    # # bevy-specific deps (from https://github.com/bevyengine/bevy/blob/main/docs/linux_dependencies.md)
    pkgconfig
    udev
    alsaLib
    lutris
    x11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    vulkan-tools
    vulkan-headers
    vulkan-loader
    vulkan-validation-layers

    (
      writeScriptBin "watch" ''
        #!${stdenv.shell}
        cd ${toString ./.} && ${watchexec}/bin/watchexec -e rs --clear "run"
        ${cargo}/bin/cargo run --features bevy/dynamic
      ''
    )

    (
      writeScriptBin "run" ''
        #!${stdenv.shell}
        ${cargo}/bin/cargo run --features bevy/dynamic
      ''
    )
  ];

}
