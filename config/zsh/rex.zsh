# rex-layout only replays commands still running when a snapshot is taken.
if [[ -n $REX_BLOCK ]]; then
  autoload -Uz add-zsh-hook

  _rex_preexec() {
    local file="${XDG_STATE_HOME:-$HOME/.local/state}/rex-layout/running/$REX_BLOCK.json"
    (
      umask 077
      mkdir -p -- "${file:h}" || return
      local temp=$(mktemp "${file}.XXXXXX") || return
      if jq -n --argjson pid "$$" --arg shell "${commands[zsh]}" \
          --arg cwd "$PWD" --arg command "$1" \
          '{pid: $pid, shell: $shell, cwd: $cwd, command: $command}' > "$temp"; then
        mv -f -- "$temp" "$file"
      else
        rm -f -- "$temp"
      fi
    ) 2>/dev/null
    return 0
  }

  _rex_precmd() {
    local file="${XDG_STATE_HOME:-$HOME/.local/state}/rex-layout/running/$REX_BLOCK.json"
    if [[ -f $file ]] && jq -e --argjson pid "$$" '.pid == $pid' "$file" >/dev/null 2>&1; then
      rm -f -- "$file"
    fi
    return 0
  }

  add-zsh-hook preexec _rex_preexec
  add-zsh-hook precmd _rex_precmd
fi
