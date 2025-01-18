#!/bin/bash
# Get the current active space index
CURRENT_SPACE=$(yabai -m query --spaces --space | jq '.index')

# Get the number of windows in the current space
WINDOW_COUNT=$(yabai -m query --windows --space | jq '[.[] | select(.["is-visible"] == true and .["is-floating"] == false)] | length')

# Define padding values for each monitor
SINGLE_WINDOW_PADDING_4K=600
DEFAULT_PADDING_4K=10

SINGLE_WINDOW_PADDING_LAPTOP=300
DEFAULT_PADDING_LAPTOP=10

# Call the C program to detect if the internal laptop display is active
./detect_display
DISPLAY_STATUS=$?

# Check the display status and set padding values based on the result
if [ "$DISPLAY_STATUS" -eq 0 ]; then
  # Internal laptop display is active
  SINGLE_WINDOW_PADDING=$SINGLE_WINDOW_PADDING_LAPTOP
  DEFAULT_PADDING=$DEFAULT_PADDING_LAPTOP
else
  # External 4K monitor is active (assuming LG Ultragear)
  SINGLE_WINDOW_PADDING=$SINGLE_WINDOW_PADDING_4K
  DEFAULT_PADDING=$DEFAULT_PADDING_4K
fi

if [ "$WINDOW_COUNT" -eq 1 ]; then
  # Get the current padding value
  CURRENT_PADDING=$(yabai -m config --space $CURRENT_SPACE left_padding)

  # Toggle padding between default and single window padding
  if [ "$CURRENT_PADDING" -eq $DEFAULT_PADDING ]; then
    yabai -m config --space $CURRENT_SPACE left_padding $SINGLE_WINDOW_PADDING
    yabai -m config --space $CURRENT_SPACE right_padding $SINGLE_WINDOW_PADDING
  else
    yabai -m config --space $CURRENT_SPACE left_padding $DEFAULT_PADDING
    yabai -m config --space $CURRENT_SPACE right_padding $DEFAULT_PADDING
  fi
else
  # Toggle fullscreen for the focused window
  yabai -m window --toggle zoom-fullscreen
fi
