.PHONY: build switch test clean

# The name of the nixosConfiguration in the flake
NIXNAME ?= ArchMac

# We need to do some OS switching below.
UNAME := $(shell uname)

default: switch

# Build and switch to the configuration
switch:
ifeq ($(UNAME), Darwin)
	nix build --extra-experimental-features nix-command --extra-experimental-features flakes ".#darwinConfigurations.${NIXNAME}.system"
		./result/sw/bin/darwin-rebuild switch --flake "$$(pwd)#${NIXNAME}"
else
sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake ".#${NIXNAME}"
endif

# Test the configuration without switching
test:
	darwin-rebuild test --flake .#

# Clean build artifacts
clean:
	nix-collect-garbage -d

# Update all flake inputs
update:
	nix flake update

# Show the current system generation
show:
	darwin-rebuild --list-generations

help:
	@echo "Available targets:"
	@echo "  build   - Build the configuration"
	@echo "  switch  - Build and switch to the configuration"
	@echo "  test    - Test the configuration without switching"
	@echo "  clean   - Clean build artifacts"
	@echo "  update  - Update all flake inputs"
	@echo "  show    - Show system generations"
