#!/usr/bin/env fish
# ~/.config/hypr/switch_output.fish
# Usage: switch_output.fish <sink_name>
# Example: switch_output.fish alsa_output.pci-0000_00_1b.0.analog-stereo

if test (count $argv) -eq 0
    echo "Usage: switch_output.fish <sink_name>"
    echo "List sinks with: pactl list short sinks"
    exit 1
end

set TARGET_SINK $argv[1]

# Set default sink
pactl set-default-sink $TARGET_SINK

# Move all existing sink-inputs (active streams) to the new sink
for sid in (pactl list short sink-inputs | awk '{print $1}')
    pactl move-sink-input $sid $TARGET_SINK >/dev/null 2>&1
end

echo "Switched output to $TARGET_SINK"
