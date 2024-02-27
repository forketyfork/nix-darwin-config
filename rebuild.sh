#!/bin/sh

set -e
pushd ~/dev/github/forketyfork/nix-darwin-config
nvim flake.nix
alejandra . &>/dev/null
git diff -U0 *.nix
echo "darwin-rebuild..."
darwin-rebuild switch --flake .#work &>nixos-switch.log || (cat nixos-switch.log | grep --color error && false)
gen=$(darwin-rebuild --list-generations | grep current)
git commit -am "$gen"
popd
