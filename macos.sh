#!/bin/bash

# close any open System Settings panes, to prevent them from overriding
# settings we’re about to change
killall "System Settings"

# csk for the administrator password upfront
sudo -v

# keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

###############################################################################
# General UI/UX                                                               #
###############################################################################

# disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
###############################################################################

# set a blazingly fast keyboard repeat rate
defaults write -g KeyRepeat -int 1
defaults write -g InitialKeyRepeat -int 10

# configuring long press behaviour - for vim
defaults write -g ApplePressAndHoldEnabled -bool false

# remapping caps lock to ctrl
hidutil property --set '{
  "UserKeyMapping": [
    {
      "HIDKeyboardModifierMappingSrc": 0x700000039,
      "HIDKeyboardModifierMappingDst": 0x7000000E0
    }
  ]
}'

###############################################################################
# Screen                                                                      #
###############################################################################

# save screenshots to the desktop
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

###############################################################################
# Finder                                                                      #
###############################################################################

# finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

echo "Log out and log back in or restart your system for the changes to take effect"
