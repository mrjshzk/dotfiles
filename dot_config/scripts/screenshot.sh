#!/usr/bin/env bash
set -euo pipefail

SAVE_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$SAVE_DIR"

FILE="$SAVE_DIR/screenshot_$(date +%Y-%m-%d_%H%M%S).png"

choice="$(printf '%s\n' 'Region' 'Window' 'Monitor' | rofi -dmenu -i -p 'Screenshot')"

case "$choice" in
Region)
    geometry="$(slurp)" || exit 0
    grim -g "$geometry" "$FILE"
    ;;

Window)
    desktop="${XDG_CURRENT_DESKTOP:-}"

    if [[ "$desktop" == *sway* ]]; then
        tree="$(swaymsg -t get_tree)"
        filter='.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"'
        geometry="$(printf '%s' "$tree" | jq -r "$filter")"

    elif [[ "$desktop" == *Hyprland* ]]; then
        window="$(hyprctl -j activewindow)"
        filter='"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'
        geometry="$(printf '%s' "$window" | jq -r "$filter")"

    else
        notify-send "Screenshot" "Window capture supports Sway or Hyprland." || true
        exit 1
    fi

    [ -n "$geometry" ] || exit 1
    grim -g "$geometry" "$FILE"
    ;;

Monitor)
    monitor="$(slurp -o)" || exit 0
    output="$(printf '%s' "$monitor" | awk '{print $NF}')"
    grim -o "$output" "$FILE"
    ;;

*)
    exit 0
    ;;
esac

wl-copy < "$FILE"

if command -v notify-send >/dev/null 2>&1; then
    notify-send "Screenshot saved" "$FILE"
fi
