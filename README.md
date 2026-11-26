# NixOS System Configurations

This repository contains my NixOS system configurations. This repository
isn't meant to be a turnkey solution to copying my setup or learning Nix,
so I want to apologize to anyone trying to look for something "easy". I've
tried to use very simple Nix practices wherever possible, but if you wish
to copy from this, you'll have to learn the basics of Nix, NixOS, etc.

I don't claim to be an expert at Nix or NixOS, so there are certainly
improvements that could be made! Feel free to suggest them, but please don't
be offended if I don't integrate them, I value having my config work over
having it be optimal.

## How I Work

I like to use macOS as the host OS and NixOS within a VM as my primary
development environment. I use the graphical applications on the host
(browser, calendars, mail app, iMessage, etc.) but I do almost everything
dev-related in the VM (editor, compilation, databases, etc.).

Inevitably I get asked **why?** I genuinely like the macOS application
ecosystem, and I'm pretty "locked in" to their various products such as
iMessage. I like the Apple hardware, and I particularly like that my hardware
always Just Works with excellent performance, battery life, and service.
However, I prefer the Linux environment for almost all my dev work. I find
that modern computers are plenty fast enough for the best of both worlds.

Here is what it ends up looking like:

![Screenshot](https://raw.githubusercontent.com/mitchellh/nixos-config/main/.github/images/screenshot.png)

Note that I usually full screen the VM so there isn't actually a window,
and I three-finger swipe or use other keyboard shortcuts to active that
window.

### Common Questions Related To This Workflow

**How does web application development work?** I use the VM's IP. Even
though it isn't strictly static, it never changes since I rarely run
other VMs. You just have to make sure software in the VM listens
on `0.0.0.0` so that it isn't only binding to loopback.

**Does copy/paste work?** Yes.

**Do you use shared folders?** I set up a shared folder so I can access
the home directory of my host OS user, but I very rarely use it. I primarily
only use it to access browser downloads. You can see this setup in these
Nix files.

**Do you ever launch graphical applications in the VM?** Sometimes, but rarely.
I'll sometimes do OAuth flows and stuff using FireFox in the VM. Most of the
time, I use the host OS browser.

**Do you have graphical performance issues?** For the types of graphical
applications I run (GUIs, browsers, etc.), not really. VMware (and other
hypervisors) support 3D acceleration on macOS and I get really smooth
rendering because of it.

**This can't actually work! This only works on a powerful workstation!**
I've been doing this since late 2020, and I've developed
[a lot of very real software](https://www.hashicorp.com/). It works for me.
I also use this VM on a MacBook Pro (to be fair, it is maxed out on specs),
and I have no issues whatsoever.

**Does this work with Apple Silicon Macs?** Yes, I use VMware Fusion, and this
repository also includes a UTM configuration. I've been using an Apple Silicon
Mac full time since Nov 2021 with this setup.

**Does this work on Windows?** The maintained VM configurations target
Apple Silicon Macs. See the WSL section below for the Windows environment.

## Setup (VM)

Video: <https://www.youtube.com/watch?v=ubDMLoWz76U>

**Note:** This setup guide covers VMware Fusion because that is the hypervisor
I use day to day. A separate UTM configuration is also available.

You can download the NixOS ISO from the
[official NixOS download page](https://nixos.org/download.html#nixos-iso).
Use the `aarch64` ISO with the maintained VM configurations in this repository.

Create a VMware Fusion VM with the following settings. The primary VM
configuration targets VMware Fusion; use the separate UTM target for UTM.

* ISO: NixOS 25.05 or later.
* Disk: SATA 150 GB+
* CPU/Memory: I give at least half my cores and half my RAM, as much as you can.
* Graphics: Full acceleration, full resolution, maximum graphics RAM.
* Network: Shared with my Mac.
* Remove sound card, remove video camera, remove printer.
* Profile: Disable almost all keybindings
* Boot Mode: UEFI

Boot the VM, and using the graphical console, change the root password to "root":

```
$ sudo su
$ passwd
# change to root
```

At this point, verify `/dev/sda` exists. This is the expected block device
where the Makefile will install the OS. If you setup your VM to use SATA,
this should exist. If `/dev/nvme` or `/dev/vda` exists instead, you didn't
configure the disk properly. Note, these other block device types work fine,
but you'll have to modify the `bootstrap0` Makefile task to use the proper
block device paths.

Also at this point, I recommend making a snapshot in case anything goes wrong.
I usually call this snapshot "prebootstrap0". This is entirely optional,
but it'll make it super easy to go back and retry if things go wrong.

Run `ifconfig` and get the IP address of the first device. It is probably
`192.168.58.XXX`, but it can be anything. In a terminal with this repository
set this to the `NIXADDR` env var:

```
export NIXADDR=<VM ip address>
```

The Makefile defaults to the macOS configuration when run on Darwin. Before
bootstrapping an ARM-based VM, set `NIXNAME` to the appropriate VM
configuration:

```
export NIXNAME=vm-aarch64
```

**Other Hypervisors:** If you are using UTM, use `vm-aarch64-utm`. Note that
the UTM environment isn't exactly equivalent to VMware, but both work.

Perform the initial bootstrap. This will install NixOS on the VM disk image
but will not setup any other configurations yet. This prepares the VM for
any NixOS customization:

```
make vm/bootstrap0
```

After the VM reboots, run the full bootstrap, this will finalize the
NixOS customization using this configuration:

```
make vm/bootstrap
```

You should have a graphical functioning dev VM.

At this point, I never use Mac terminals ever again. I clone this repository
in my VM and I use the other Make tasks such as `make test`, `make switch`, etc.
to make changes my VM.

## Setup (macOS/Darwin)

**THIS IS OPTIONAL AND UNRELATED TO THE VM WORK.** I recommend you ignore
this unless you're interested in using Nix to manage your Mac too.

I share some of my Nix configurations with my Mac host and use Nix
to manage _some_ aspects of my macOS installation, too. This uses the
[nix-darwin](https://github.com/LnL7/nix-darwin) project. I don't manage
_everything_ with Nix, for example I don't manage apps, some of my system
settings, Homebrew, etc. I plan to migrate some of those in time.

To utilize the Mac setup, first install Nix using some Nix installer.
There are two great installers right now:
[nix-installer](https://github.com/DeterminateSystems/nix-installer)
by Determinate Systems and [Flox](https://floxdev.com/). The point of both
for my configs is just to get the `nix` CLI with flake support installed.

The two Apple Silicon Mac profiles follow Mitchell Hashimoto's
[per-host Darwin layout](https://github.com/mitchellh/nixos-config):

- `macbook-m5`: the new MacBook Pro, preserving the existing Homebrew
  apps, desktop preferences, 1Password agent, and Rex remote hosts, including
  `macbook-m3-max-rex.tailed558.ts.net`.
- `macbook-m3-max`: the old MacBook Pro as an unattended agent runner,
  following Mitchell's headless Mac Studio settings. It
  shares the shell and dotfiles, installs Amp, Claude Code, and Codex through
  Nix, disables computer sleep, enables restart after a system freeze, and
  enables key-only SSH. It does not manage desktop apps through
  Homebrew or rely on the desktop 1Password agent.

Both import `machines/darwin-shared.nix`. The existing state version stays
at 5; a new profile name is not a reason to migrate it.

Nushell is the login shell on both Macs and the Linux profiles, following
Mitchell's shared Darwin Nushell module. Home Manager owns its configuration,
including direnv-instant and the existing Oh My Posh theme. On macOS the native
Nushell config directory points to `~/.config/nushell`, so it also works before
`XDG_CONFIG_HOME` is set. Nushell imports the Nix/Home Manager environment through
a non-interactive zsh login shell; zsh remains available as a fallback. The
Darwin module assumes the existing `uzaaft` account has uid 501.

After installing Nix and cloning this repo at
`~/repositories/github.com/uzaaft/dotfiles`, build without activation:

```sh
make build NIXNAME=macbook-m5
# On the old MacBook Pro (macbook-m3-max):
make build NIXNAME=macbook-m3-max
```

Review the build, then run `make switch NIXNAME=macbook-m5` on the new MacBook
or `make switch NIXNAME=macbook-m3-max` on the old MacBook Pro, after completing
the handoff checklist below. Activation names the new MacBook `macbook-m5`
and the runner's macOS host `macbook-m3-max`. Rex uses its separate embedded
Tailscale node `macbook-m3-max-rex.tailed558.ts.net`; the OS must not compete for
that name. Afterward, `make` selects `macbook-m3-max` on hostname `macbook-m3-max` and
otherwise defaults to `macbook-m5` on Darwin. Use an explicit `NIXNAME` for
the first activation. VM targets still default to `vm-aarch64`; the cache
target uses `NIXCACHE_NAME` instead. `make cache` pushes that system's closure
to Snowstead's `dotfiles` cache after a one-time `snowstead login`.

Before switching the runner, provision `~/.ssh/authorized_keys` for remote
access and a dedicated `~/.ssh/id_ed25519` key for Git authentication and
signing. Authorize its public key with the relevant Git hosts. Keep the
MacBook plugged in; disabling idle sleep does not disable lid-close sleep
or bypass FileVault's unlock requirement after reboot. Tailscale is shared
by both profiles and requires one-time authentication. Agent credentials
and registration of the MacBook as an Amp runner are separate setup steps;
this configuration does not enroll it automatically.

### Runner handoff (requires separate activation approval)

The `macbook-m3-max` profile installs the pinned Rex CLI and an `org.nixos.rex`
system LaunchDaemon. It starts at boot, restarts after exit, and runs as
`uzaaft`, not root. Its HOME, socket, and default state directory match the
existing personal server; it enables the embedded `macbook-m3-max-rex` Tailscale
node without embedding enrollment credentials. Logs go to `/var/log/rex.log`.
FileVault still requires a human unlock after reboot. This is not a promise
of unattended cold-boot recovery, and macOS GUI permissions are not granted
by the daemon.

Before first activation:

- Establish and test an independent SSH login to the OS node (after activation,
  `macbook-m3-max.tailed558.ts.net`, IP `100.71.94.108`), not the Rex-only node
  `macbook-m3-max-rex.tailed558.ts.net`. Keep this recovery connection open and have
  interactive sudo available. Confirm the OS node's DNS name after activation.
- Save work in active Rex sessions. Back up `~/Library/Application Support/rex`
  once the old server is stopped; never run two servers against its live
  snapshot or Tailscale state. Keep the old app/binary for rollback until
  the pinned server has successfully restored the state.
- Quit the old Mac's Rex app and disable/unload its personal server
  LaunchAgent before starting the new daemon. Do this from SSH or the local
  console, not from a session that the handoff will terminate. Do not launch
  Rex.app or let it replace/restart the server during the handoff.
- Transfer the reviewed configuration without overwriting the old checkout's
  dirty Neovim submodule. Home Manager will back up the unmanaged SSH config
  as `~/.ssh/config.backup`; resolve any existing backup collision first.
  Its replacement preserves the two VM jump-host entries and connection
  multiplexing, uses `id_ed25519` with `IdentityAgent none`, and includes
  Rex's terminfo fallback. It does not change `authorized_keys` or private keys.
- Reauthenticate Claude, verify Amp credentials, and confirm required Git
  hosts accept the dedicated key. No agent login or Amp runner registration
  is performed by activation.

After activation, verify `launchctl print system/org.nixos.rex`, Rex's
Tailscale connection and restored sessions, key-only SSH, Git signing and
fetching, and an agent command in a new Rex terminal. Test logout recovery
and a supervised reboot with FileVault unlock before calling the machine
unattended-ready. Do not remove the old Rex installation before these checks.

### Runner app cleanup (not automatic)

Disabling Homebrew management on the runner does **not** uninstall existing
apps. The owner approved removal of exactly the following 20 casks on the old
M3 Max MacBook, conditional on verification of the runner handoff. Do not
uninstall them before the post-activation checks above pass. This approval
does not authorize activation, stopping existing Rex sessions, or removing
other apps; the earlier no-activation restriction remains in effect.

The approved cask list is:
`alt-tab`, `betterdisplay`, `bobrwm`, `chatgpt`, `claude` (GUI only), `codexbar`,
`clop`, `discord`, `grok-bot`, `hermes-desktop`, `hiddenbar`, `imageoptim`,
`linear`, `linear-linear`, `logi-options+`, `slack`, `tableplus`, `tinycast`,
`wispr-flow`, and `zulip`. Browser removals require separate approval.
Verify legacy/duplicate cask tokens against `brew list --cask` before removal.

Keep Xcode and command-line build tools, Tailscale, Homebrew formulae,
credentials, and at least one recovery terminal/browser. Keep 1Password,
Cloudflare WARP, Amphetamine, and the old Rex installation until independent
authentication, networking, sleep prevention, and startup are verified.
Remove duplicate Homebrew agent CLIs only after checking that the Nix-managed
versions are actually selected by PATH. Prefer ordinary cask uninstalls;
do not use `--zap`, broad application-folder deletion, or blanket
`brew bundle cleanup --force` while credentials and build dependencies are
still being migrated. No app removal is part of activation.

If activation reports existing-file conflicts, follow the error message
(some folders may need permissions changed or files moved aside).

**WARNING: Don't do this without reading the source.** This repository
is and always has been _my_ configurations. If you blindly run this,
your system may be changed in ways that you don't want. Read my source!

## Setup (WSL)

**THIS IS OPTIONAL AND UNRELATED TO THE VM WORK.** I recommend you ignore
this unless you're interested in using Nix to manage your WSL
(Windows Subsystem for Linux) environment, too.

I use Nix to build a WSL root tarball for Windows. I then have my entire
Nix environment on Windows in WSL too, which I use to for example run
Neovim amongst other things. My general workflow is that I only modify
my WSL environment outside of WSL, rebuild my root filesystem, and
recreate the WSL distribution each time there are system changes. My system
changes are rare enough that this is not annoying at all.

To create a WSL root tarball, you must be running on a Linux machine
that is able to build `x86_64` binaries (either directly or cross-compiling).
My `aarch64` VMs are all properly configured to cross-compile to `x86_64`
so if you're using my NixOS configurations you're already good to go.

Run `make wsl`. This will take some time but will ultimately output
a tarball in `./result/tarball`. Copy that to your Windows machine.
Once it is copied over, run the following steps on Windows:

```
$ wsl --import nixos .\nixos .\path\to\tarball.tar.gz
...

$ wsl -d nixos
...

# Optionally, make it the default
$ wsl -s nixos
```

After the `wsl -d` command, you should be dropped into the Nix environment.
_Voila!_
