#!/bin/sh
# Start / Reload waybar

killall waybar

waybar -l debug -c ~/.config/waybar/config.json -s ~/.config/waybar/style.css
