#!/bin/sh
defaults write com.apple.desktopservices DSDontWriteNetworkStores true
cat ./installed_apps/brew.txt| while read line
do
  brew install $line
done
cat ./installed_apps/cargo.txt | while read line
do
  cargo install $line
done

