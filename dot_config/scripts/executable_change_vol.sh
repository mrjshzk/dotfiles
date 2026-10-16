
#!/usr/bin/env bash

# Usage: vol.sh [+/-]    (e.g. vol.sh + to increase, vol.sh - to decrease)

# Increment or decrement volume
wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%"$1"

# Get current volume (decimal 0-1 float)
volume_float=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')

# Calculate percentage (round to integer)
volume_percentage=$(awk -v v="$volume_float" 'BEGIN { printf "%d\n", v*100 }')
echo $volume_percentage
