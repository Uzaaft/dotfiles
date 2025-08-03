# Connectivity info for Linux VM
NIXADDR ?= unset
NIXPORT ?= 22
NIXUSER ?= uzaaft

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# SSH options that are used. These aren't meant to be overridden but are
# reused a lot so we just store them up here.
SSH_OPTIONS=-o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

# The name of the nixosConfiguration in the flake
NIXNAME ?= vm-aarch64

# We need to do some OS switching below.
UNAME := $(shell uname)

default: switch

# Build and switch to the configuration
switch:
ifeq ($(UNAME), Darwin)
	echo "Macos build"
	NIXPKGS_ALLOW_UNFREE=1 nix build --impure --extra-experimental-features nix-command --extra-experimental-features flakes ".#darwinConfigurations.ArchMac.system"
	sudo NIXPKGS_ALLOW_UNFREE=1 ./result/sw/bin/darwin-rebuild switch --impure --flake "$$(pwd)#ArchMac"
else
	sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --impure --flake ".#${NIXNAME}"
endif

vm/bootstrap0:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		parted /dev/nvme0n1 -- mklabel gpt; \
		parted /dev/nvme0n1 -- mkpart primary 512MB -8GB; \
		parted /dev/nvme0n1 -- mkpart primary linux-swap -8GB 100\%; \
		parted /dev/nvme0n1 -- mkpart ESP fat32 1MB 512MB; \
		parted /dev/nvme0n1 -- set 3 esp on; \
		sleep 1; \
		mkfs.btrfs -L nixos /dev/nvme0n1p1; \
		mkswap -L swap /dev/nvme0n1p2; \
		mkfs.fat -F 32 -n boot /dev/nvme0n1p3; \
		sleep 1; \
		mount /dev/disk/by-label/nixos /mnt; \
		mkdir -p /mnt/boot; \
		mount /dev/disk/by-label/boot /mnt/boot; \
		nixos-generate-config --root /mnt; \
		sed --in-place '/system\.stateVersion = .*/a \
						nix.package = pkgs.nixVersions.latest;\n \
						nix.extraOptions = \"experimental-features = nix-command flakes\";\n \
						nix.settings.substituters = [\"https://uzaaft-nixos-config.cachix.org\"];\n \
						nix.settings.trusted-public-keys = [\"uzaaft-nixos-config.cachix.org-1:Aq0SI5W8qOROEbbYHS2rfukZpaDmFsjYAfQGDyJE/Pw=\"];\n \
	 					services.openssh.enable = true;\n \
						services.openssh.settings.PasswordAuthentication = true;\n \
						services.openssh.settings.PermitRootLogin = \"yes\";\n \
						systemd.network.enable = true; \n \
						networking.networkmanager.enable = true; \n \
						users.users.root.initialPassword = \"root\";\n \
					' /mnt/etc/nixos/configuration.nix; \
		nixos-install --no-root-passwd && reboot; \
	"

# after bootstrap0, run this to finalize. After this, do everything else
# in the VM unless secrets change.
vm/bootstrap:
	NIXUSER=root $(MAKE) vm/copy
	NIXUSER=root $(MAKE) vm/switch
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		sudo reboot; \
	"

# copy the Nix configurations into the VM.
vm/copy:
	rsync -av -e 'ssh $(SSH_OPTIONS) -p$(NIXPORT)' \
	  --exclude='vendor/' \
	  --exclude='.git/' \
	  --exclude='.git-crypt/' \
	  --exclude='iso/' \
	  --rsync-path="sudo rsync" \
	  $(MAKEFILE_DIR)/ $(NIXUSER)@$(NIXADDR):/nix-config

# run the nixos-rebuild switch command. This does NOT copy files so you
# have to run vm/copy before.
vm/switch:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake \"/nix-config#${NIXNAME}\" \
	"

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

cache:
	nix build '.#nixosConfigurations.$(NIXNAME).config.system.build.toplevel' --json |
	  jq -r '.[].outputs | to_entries[].value' |
	  cachix push uzaaft-nixos-config
help:
	@echo "Available targets:"
	@echo "  build   - Build the configuration"
	@echo "  switch  - Build and switch to the configuration"
	@echo "  test    - Test the configuration without switching"
	@echo "  clean   - Clean build artifacts"
	@echo "  update  - Update all flake inputs"
	@echo "  show    - Show system generations"
