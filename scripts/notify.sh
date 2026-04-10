#!/bin/bash
# Core notification sender — osascript (works on all macOS versions including 14+).
# Usage: notify.sh <title> <message> [sound]
# Sounds: Glass, Ping, Basso, Blow, Bottle, Frog, Funk, Hero, Morse, Pop, Purr, Sosumi, Tink

TITLE="${1:-Claude Code}"
MESSAGE="${2:-Notification}"
SOUND="${3:-Ping}"

osascript -e "display notification \"${MESSAGE}\" with title \"${TITLE}\" sound name \"${SOUND}\""
