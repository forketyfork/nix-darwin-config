#!/bin/bash

set -e
pushd ~/dev/github/forketyfork/nix-darwin-config
nvim flake.nix
alejandra . 
git diff -U0 ./*.nix
echo "darwin-rebuild..."
darwin-rebuild switch --flake .#work &> nixos-switch.log || (grep --color error nixos-switch.log && false)
gen=$(darwin-rebuild --list-generations | grep current)
git commit -am "$gen"
popd
