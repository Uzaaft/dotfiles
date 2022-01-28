# Dotfiles

## Setting things up
### Requirements:
* stow
* git
* [LunarVim](https://github.com/LunarVim/LunarVim)
* [WezTerm](https://wezfurlong.org/wezterm/)

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
Clone into your `$HOME` directory or `~`

```bash
git clone https://github.com/ChristianChiarulli/Machfiles.git ~
```

Run `stow` to symlink everything or just select what you want

```bash
stow */ # Everything (the '/' ignores the README)
```

```bash
stow zsh # Just my zsh config
```
