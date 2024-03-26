# Dotfiles

## Setting things up
### Requirements:
* stow
* git
* [LunarVim](https://github.com/LunarVim/LunarVim)
* [WezTerm](https://wezfurlong.org/wezterm/)

#### Custom requirements
- https://github.com/uzaaft/extend

### Fonts:
- [FiraCode Nerd Font](firaCode): My preferred font
- Any of the [Nerd Fonts]

On macOS with Homebrew, choose one of the [Nerd Fonts],
for example, here are some popular fonts:

```shell
brew tap homebrew/cask-fonts
brew search nerd-font
brew install --cask font-fira-code-nerd-font
brew install --cask font-victor-mono-nerd-font
brew install --cask font-iosevka-nerd-font-mono
brew install --cask font-hack-nerd-font
```

### Installing:
Clone into your `$GIT_REPO` directory or `~`

```bash
git clone https://github.com/uzaaft/dotfiles.git ~
```

Run `stow` to symlink stuff
```bash
stow .config # Everything inside .config
```

To disable automatic reopen on reboot:
```bash
sudo chown root ~/Library/Preferences/ByHost/com.apple.loginwindow*
sudo chmod 000 ~/Library/Preferences/ByHost/com.apple.loginwindow*
```
To undo:
```bash
sudo rm -f ~/Library/Preferences/ByHost/com.apple.loginwindow*
```
```

Other tweaks:
Using sudo with fingerprint:
```bash
sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
sudo nvim /etc/pam.d/sudo_local
```
