#!/bin/bash
# shellcheck shell=bash
WID=$(xdotool search --name "Select Setup Language")
xdotool windowactivate $WID key Tab key Enter
sleep 1
WID=$(xdotool search --name "Setup - IL-2 Sturmovik Great Battles" | tail -n 1)
xdotool windowactivate --sync $WID key Tab key Tab key enter
sleep 1
xdotool windowactivate --sync $WID key Tab key Tab key enter
sleep 10
xdotool windowactivate --sync $WID key Tab key enter