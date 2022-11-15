#!/bin/sh

brew services stop fyabai
# create yabai-cert as a keychain certificate
codesign -fs 'yabai-cert' $(brew --prefix fyabai)/bin/yabai
# reconfigure the scripting addition again
sudo bash -c "cat <<EOF > /private/etc/sudoers.d/yabai
$(whoami) ALL = (root) NOPASSWD: sha256:$(shasum -a 256 $(brew --prefix fyabai)/bin/yabai) --load-sa
EOF"
sudo $(brew --prefix fyabai)/bin/yabai --load-sa
