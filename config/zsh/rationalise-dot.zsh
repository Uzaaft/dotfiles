# expand ... to ../.. recursively
function _rationalise-dot { # This was written entirely by Mikael Magnusson (Mikachu)
  local MATCH # keep the regex match from leaking to the environment
  if [[ $LBUFFER =~ '(^|/| |      |'$'\n''|\||;|&)\.\.$' ]]; then
    LBUFFER+=/
    zle self-insert
    zle self-insert
  else
    zle self-insert
  fi
}
zle -N _rationalise-dot
bindkey . _rationalise-dot
bindkey -M isearch . self-insert # without this, typing . aborts incr history search
