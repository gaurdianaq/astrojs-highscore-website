{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/11e805f9935f6ab4b049351ac14f2d1aa93cf1d3.tar.gz") {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.nodejs-16_x
  ];

  shellHook = ''
    mkdir -p .nix-node
    export NODE_PATH=$PWD/.nix-node
    export NPM_CONFIG_PREFIX=$PWD/.nix-node
    export PATH=$NODE_PATH/bin:$PATH
  '';
}