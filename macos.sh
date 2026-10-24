#!/usr/bin/env bash
# Basic macOS preferences. Safe to re-run. Keyboard and trackpad apply after logout.
set -euo pipefail

if [[ -t 1 ]]; then CHECK=$'\033[32m✓\033[0m'; else CHECK='✓'; fi
ok() { printf '  %s %s\n' "$CHECK" "$*"; }

# Stop System Settings from overwriting what we change
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"         # list view
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"         # search the current folder
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder NewWindowTarget -string "PfHm"              # new window opens ~
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true # no .DS_Store on network drives
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true     # ...nor on USB drives
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false # save dialogs default to disk, not iCloud
ok "Finder: list view, path and status bars, file extensions, no .DS_Store on network or USB"

defaults write NSGlobalDomain KeyRepeat -int 2         # fastest values System Settings allows
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false # no “smart quotes” in pasted code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
# Press-and-hold accent popup (é, ã) and autocorrect are left untouched on purpose.
ok "Keyboard: fast key repeat, no smart quotes or dashes"

defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true # tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
ok "Trackpad: tap to click"

defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mru-spaces -bool false # keep Spaces in a fixed order
ok "Dock: hides automatically, no recent apps, Spaces in a fixed order"

sudo -v
# Touch ID for sudo; sudo_local survives macOS updates (macOS 14+)
if ! grep -qs '^auth.*pam_tid.so' /etc/pam.d/sudo_local; then
  sed 's/^#auth/auth/' /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local >/dev/null
fi
ok "Touch ID for sudo"
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on >/dev/null
ok "Firewall on"

killall Finder Dock SystemUIServer 2>/dev/null || true
ok "Finder and Dock restarted (keyboard and trackpad apply after logout)"
