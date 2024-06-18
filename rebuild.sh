#!/usr/bin/env bash

# Update and rebuild the nix-darwin configuration

set -eu

pushd ~/dev/github/forketyfork/nix-darwin-config
# open flake.nix in an editor and allow the user to update it
nvim flake.nix

# format the nix files
alejandra .

# show git diff for the nix files
git diff -U0 ./*.nix

# run darwin-rebuild with the updated nix files, output the log to the nixos-switch.log file
# fail when there are errors, print them out to the console
echo "darwin-rebuild..."
darwin-rebuild switch --flake .#work &>nixos-switch.log || (grep --color error nixos-switch.log && false)

# the current generation
gen=$(darwin-rebuild --list-generations | grep current)

# use the current generation as the commit contents
git commit -am "$gen"

# return to the initial directory
popd
