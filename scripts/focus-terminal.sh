#!/bin/bash
# Focus Cursor and open terminal panel
osascript -e 'tell application "Cursor" to activate' \
          -e 'delay 0.2' \
          -e 'tell application "System Events" to keystroke "`" using control down'
