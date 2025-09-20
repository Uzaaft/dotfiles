function openwin --description 'Open new window in specified application'
    osascript -e "tell application \"$argv[1]\" to activate" -e 'tell application "System Events" to keystroke "n" using command down'
end