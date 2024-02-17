#!/bin/bash
# shellcheck shell=bash
WID=$(xdotool search --name "Wine Mono Installer")
xdotool windowactivate $WID key Tab key Enter