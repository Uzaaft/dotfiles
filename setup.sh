#!/bin/sh
defaults write com.apple.desktopservices DSDontWriteNetworkStores true

# Disable reopen windows when logging back in
# To reverse this, do:
# sudo rm -f ~/Library/Preferences/ByHost/com.apple.loginwindow.*
sudo chown root ~/Library/Preferences/ByHost/com.apple.loginwindow.*
sudo chmod 000 ~/Library/Preferences/ByHost/com.apple.loginwindow.*
