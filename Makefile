.PHONY: build switch test clean

default: build

# Build the configuration
build:
	darwin-rebuild build --flake .#

# Build and switch to the configuration
switch:
	darwin-rebuild switch --flake .#

# Test the configuration without switching
test:
	darwin-rebuild test --flake .#

# Clean build artifacts
clean:
	nix-collect-garbage -d

# Update all flake inputs
update:
	nix flake update

# Update specific input
update-input:
	@read -p "Enter input name: " input; \
	nix flake lock --update-input $$input

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
