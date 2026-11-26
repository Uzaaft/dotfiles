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

# jws NAME opens a Rex session in jj workspace NAME, adding it as REPO@NAME when
# missing; switching to it needs Remote Control on in Rex.app's settings.
# jwsr forgets the current workspace, deletes it, and closes its sessions.
if (( $+commands[rex] )); then
  jws() {
    if (( $# != 1 )); then
      print -u2 'Usage: jws NAME'
      return 1
    fi
    local session
    session=$(rex do open_workspace "name=$1" "cwd=$PWD" --json | jq -er .session_id) || return
    rex do session.select session_id="$session" > /dev/null
  }

  jwsr() {
    if (( $# )); then
      print -u2 'Usage: jwsr (from inside a workspace)'
      return 1
    fi

    local dir main_root
    dir=$(jj workspace root) || return
    main_root=$(jj workspace root --name default) || return
    if [[ "${dir:A}" == "${main_root:A}" ]]; then
      print -u2 'Refusing to remove the default workspace'
      return 1
    fi

    # Same label as project_label in rex/init.lua.
    local label="${dir:h:t}/${dir:t}"
    [[ "$label" == *@* ]] && label="${label%%@*} [${label#*@}]"

    local -a sessions
    sessions=(${(f)"$(rex ls --json | jq -r --arg label "$label" \
      '.sessions[] | select(.label == $label) | .session_id')"}) || return

    # forget snapshots the working copy first, so its commit stays in the repo.
    jj workspace forget || return
    builtin cd "$main_root" || return
    rm -rf -- "$dir" || return
    print -r -- "Removed $dir (its changes stay in the repo)"
    (( ${#sessions} )) || return 0

    # Close the caller last so its terminal survives the other closures.
    sessions=("${(@)sessions:#${REX_SESSION:-}}" "${(@M)sessions:#${REX_SESSION:-}}")
    rex kill "${sessions[@]}"
  }
fi
