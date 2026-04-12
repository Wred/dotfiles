#!/bin/bash
# Switch default audio sink via wofi menu

# Get current default sink ID
default_id=$(wpctl inspect @DEFAULT_AUDIO_SINK@ 2>/dev/null | head -1 | grep -oP 'id \K\d+')

# Get all Audio/Sink nodes from PipeWire
ids=()
plain_names=()
display_names=()

while read -r id name; do
    ids+=("$id")
    plain_names+=("$name")
    if [ "$id" = "$default_id" ]; then
        display_names+=("<span color=\"#cba6f7\">${name}</span>")
    else
        display_names+=("${name}")
    fi
done < <(pw-dump | jq -r '.[] | select(.info.props["media.class"] == "Audio/Sink") | "\(.id) \(.info.props["node.description"] // .info.props["node.nick"] // .info.props["node.name"])"')

[ ${#display_names[@]} -eq 0 ] && exit 1

chosen=$(printf '%s\n' "${display_names[@]}" | wofi --dmenu --prompt "Audio Output" \
    --location top_right --yoffset 32 \
    --width 400 --lines 5 --dynamic-lines \
    --cache-file /dev/null \
    -D hide_search=true -D close_on_focus_loss=true \
    --allow-markup)
[ -z "$chosen" ] && exit 0

# Strip any markup from the selection before matching
chosen_plain=$(echo "$chosen" | sed 's/<[^>]*>//g')

for i in "${!plain_names[@]}"; do
    if [ "${plain_names[$i]}" = "$chosen_plain" ]; then
        wpctl set-default "${ids[$i]}"
        exit 0
    fi
done
