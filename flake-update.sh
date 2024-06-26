#!/usr/bin/env bash

# Update and rebuild the nix-darwin configuration

set -eu

pushd ~/dev/github/forketyfork/nix-darwin-config

# update the flake
nix flake update

# build the system
darwin-rebuild build --flake .#work

# output the diff
nvd diff /run/current-system ./result

# cleanup
rm -rf ./result

popd
