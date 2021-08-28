if status --is-interactive
	if test -d ~/dev/others/base16/templates/fish-shell
		set fish_function_path $fish_function_path ~/dev/others/base16/templates/fish-shell/functions
		builtin source ~/dev/others/base16/templates/fish-shell/conf.d/base16.fish
	end
  # tmux 2> /dev/null; and exec true 
end

function asend
	if test (count $argv) -ne 1
		echo "No argument given"
		return
	end

	adb shell input text (echo $argv[1] | sed -e 's/ /%s/g' -e 's/\([#[()<>{}$|;&*\\~"\'`]\)/\\\\\1/g')
end

function qrsend
	if test (count $argv) -ne 1
		echo "No argument given"
		return
	end

	qrencode -o - $argv[1] | feh --geometry 500x500 --auto-zoom -
end

function limit
	numactl -C 0,1,2 $argv
end
# Type - to move up to top parent dir which is a repository
function d
	while test $PWD != "/"
		if test -d .git
			break
		end
		cd ..
	end
end

# Fish git prompt
# set __fish_git_prompt_showuntrackedfiles 'yes'
# set __fish_git_prompt_showdirtystate 'yes'
# set __fish_git_prompt_showstashstate ''
# set __fish_git_prompt_showupstream 'none'
# set -g fish_prompt_pwd_dir_length 0
set -g __fish_git_prompt_show_informative_status 1
set -g __fish_git_prompt_hide_untrackedfiles 1

set -g __fish_git_prompt_color_branch magenta --bold
set -g __fish_git_prompt_showupstream "informative"
set -g __fish_git_prompt_char_upstream_ahead "↑"
set -g __fish_git_prompt_char_upstream_behind "↓"
set -g __fish_git_prompt_char_upstream_prefix ""

set -g __fish_git_prompt_char_stagedstate "●"
set -g __fish_git_prompt_char_dirtystate "✚"
set -g __fish_git_prompt_char_untrackedfiles "…"
set -g __fish_git_prompt_char_conflictedstate "✖"
set -g __fish_git_prompt_char_cleanstate "✔"

set -g __fish_git_prompt_color_dirtystate blue
set -g __fish_git_prompt_color_stagedstate yellow
set -g __fish_git_prompt_color_invalidstate red
set -g __fish_git_prompt_color_untrackedfiles $fish_color_normal
set -g __fish_git_prompt_color_cleanstate green --bold
# colored man output
# from http://linuxtidbits.wordpress.com/2009/03/23/less-colors-for-man-pages/
setenv LESS_TERMCAP_mb \e'[01;31m'       # begin blinking
setenv LESS_TERMCAP_md \e'[01;38;5;74m'  # begin bold
setenv LESS_TERMCAP_me \e'[0m'           # end mode
setenv LESS_TERMCAP_se \e'[0m'           # end standout-mode
setenv LESS_TERMCAP_so \e'[38;5;246m'    # begin standout-mode - info box
setenv LESS_TERMCAP_ue \e'[0m'           # end underline
setenv LESS_TERMCAP_us \e'[04;38;5;146m' # begin underline

setenv FZF_DEFAULT_COMMAND 'fd --type file --follow'
setenv FZF_CTRL_T_COMMAND 'fd --type file --follow'
setenv FZF_DEFAULT_OPTS '--height 20%'

function pvm -d "Run nova/glance commands against the PDOS openstack service"
	switch $argv[1]
	case 'image-*'
		penv glance $argv
	case 'c'
		penv cinder $argv[2..-1]
	case 'g'
		penv glance $argv[2..-1]
	case '*'
		penv nova $argv
	end
end

# Fish should not add things to clipboard when killing
# See https://github.com/fish-shell/fish-shell/issues/772
set FISH_CLIPBOARD_CMD "cat"

function fish_user_key_bindings
	bind \cz 'fg>/dev/null ^/dev/null'
	if functions -q fzf_key_bindings
		fzf_key_bindings
	end
end

function fish_prompt
	set_color brblack
	set_color blue
  echo -n [
  echo -n $USER
  echo -n @
	echo -n (hostname)
  echo -n ] ➜
	if [ $PWD != $HOME ]
		set_color brblack
		echo -n ' '
		set_color yellow
		echo -n (prompt_long_pwd)
	end
	set_color green
	printf '%s ' (__fish_git_prompt)
	set_color red
	echo -n '| '
	set_color normal
end

function prompt_long_pwd --description 'Print the current working directory'
        echo $PWD | sed -e "s|^$HOME|~|" -e 's|^/private||'
end


function fish_greeting
neofetch

	set_color normal

end
function fish_right_prompt
  set_color brblack
  	echo -n "["(date "+%H:%M")"] "
end
