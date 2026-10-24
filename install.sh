#!/usr/bin/env bash
# shellcheck disable=SC2088 # "~/..." in messages is display text
# Set up a Mac from this repo. Safe to re-run: every step checks before acting.
#
#   ./install.sh        asks a few questions first, then runs on its own
#   ./install.sh --yes  accepts every default, no questions
set -Eeuo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ASSUME_YES=false
case "${1:-}" in
  -y | --yes) ASSUME_YES=true ;;
  -h | --help) sed -n '3,6p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  "") ;;
  *) echo "unknown option: $1 (try --help)" >&2; exit 2 ;;
esac

# --- Output -------------------------------------------------------------------
if [[ -t 1 ]]; then
  BOLD=$'\033[1m' DIM=$'\033[2m' RESET=$'\033[0m'
  GREEN=$'\033[32m' YELLOW=$'\033[33m' RED=$'\033[31m' BLUE=$'\033[34m'
else
  BOLD='' DIM='' RESET='' GREEN='' YELLOW='' RED='' BLUE=''
fi

TOTAL_STEPS=8 STEP_N=0 STEP_NAME="" STEP_STATUS="" STEP_START=0
SUMMARY="" WARNINGS=""

ok() { printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$*"; }
note() { printf '  %s·%s %s\n' "$DIM" "$RESET" "$*"; }
warn() {
  printf '  %s!%s %s\n' "$YELLOW" "$RESET" "$*" >&2
  STEP_STATUS=warn
  WARNINGS+="  ${YELLOW}!${RESET} $*"$'\n'
}

# Closes the current step and records it for the summary
end_step() {
  [[ -n $STEP_NAME ]] || return 0
  local icon time="" elapsed=$((SECONDS - STEP_START))
  case $STEP_STATUS in
    ok) icon="${GREEN}✓${RESET}" ;;
    warn) icon="${YELLOW}!${RESET}" ;;
    skip) icon="${DIM}–${RESET}" ;;
    fail) icon="${RED}✗${RESET}" ;;
  esac
  ((elapsed >= 60)) && time=" ${DIM}$((elapsed / 60))m$((elapsed % 60))s${RESET}"
  ((elapsed > 0 && elapsed < 60)) && time=" ${DIM}${elapsed}s${RESET}"
  SUMMARY+="  $icon $STEP_NAME$time"$'\n'
  STEP_NAME=""
}

step() {
  end_step
  STEP_N=$((STEP_N + 1)) STEP_NAME=$1 STEP_STATUS=ok STEP_START=$SECONDS
  printf '\n%s[%d/%d]%s %s%s%s\n' "$BLUE" "$STEP_N" "$TOTAL_STEPS" "$RESET" "$BOLD" "$1" "$RESET"
}

# Marks the whole step as skipped
skip_step() {
  printf '  %s–%s %s\n' "$DIM" "$RESET" "$*"
  STEP_STATUS=skip
}

print_summary() {
  end_step
  printf '\n%sSummary%s\n%s' "$BOLD" "$RESET" "$SUMMARY"
  if [[ -n $WARNINGS ]]; then
    printf '\n%sNeeds attention%s\n%s' "$BOLD" "$RESET" "$WARNINGS"
  fi
}

on_error() {
  printf '\n  %s✗ "%s" failed (install.sh line %s).%s Fix it and run install.sh again;\n' \
    "$RED" "${STEP_NAME:-setup}" "$1" "$RESET" >&2
  printf '    steps that already worked are quick to repeat.\n' >&2
  STEP_STATUS=fail
  print_summary
}
trap 'on_error $LINENO' ERR

# ask <question> <default: y|n>; succeeds when the answer is yes
ask() {
  local answer hint="y/N"
  [[ $2 == y ]] && hint="Y/n"
  if $ASSUME_YES; then
    [[ $2 == y ]]
    return
  fi
  printf '  %s?%s %s [%s] ' "$BLUE" "$RESET" "$1" "$hint"
  read -r answer || answer=""
  [[ -t 0 ]] || echo # answers piped in: keep one question per line
  answer=$(printf '%s' "${answer:-$2}" | tr '[:upper:]' '[:lower:]')
  [[ $answer == y* ]]
}

# --- File helpers ---------------------------------------------------------------

# link <path in repo> <path under ~>
# The repo is the source of truth. Replaces old symlinks; moves a real file aside once.
link() {
  local src="$DOTFILES/$1" dst="$HOME/$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    mv "$dst" "$dst.backup-$(date +%Y%m%d%H%M%S)"
    warn "moved your existing ~/$2 to ~/$2.backup-*"
  fi
  ln -sfn "$src" "$dst"
  ok "~/$2 → $1"
}

# seed <path in repo> <path under ~>
# Copies once and never overwrites: tools write tokens and keys into these files,
# and a symlink would put them inside this public repo.
seed() {
  local src="$DOTFILES/$1" dst="$HOME/$2"
  if [[ -e "$dst" ]]; then
    ok "~/$2 already exists, kept as is"
    return
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  ok "~/$2 ← $1 (copy, edit it there)"
}

# --- Before starting: checks and questions ----------------------------------------

printf '%sdotfiles%s → setting up %s\n\n' "$BOLD" "$RESET" "$(scutil --get ComputerName 2>/dev/null || hostname)"

if [[ "$(uname -s)" != Darwin || "$(uname -m)" != arm64 ]]; then
  printf '%s✗ This setup is for Macs with Apple Silicon.%s\n' "$RED" "$RESET" >&2
  exit 1
fi

SSH_KEY="$HOME/.ssh/id_ed25519"
GIT_EMAIL=$(sed -nE 's/^[[:space:]]*email[[:space:]]*=[[:space:]]*//p' "$DOTFILES/git/config" | head -1)
MAS_IDS=$(sed -nE 's/^mas .*id:[[:space:]]*([0-9]+).*/\1/p' "$DOTFILES/Brewfile" | tr '\n' ' ')

printf '%sA few questions first; after them the setup runs on its own.%s\n' "$BOLD" "$RESET"
CREATE_SSH_KEY=false APPLY_MACOS=false INSTALL_XCODE=false
if [[ ! -f $SSH_KEY ]] && ask "Create an SSH key for GitHub?" y; then CREATE_SSH_KEY=true; fi
if ask "Apply macOS preferences (Finder, keyboard, trackpad, Dock, firewall, Touch ID for sudo)?" y; then
  APPLY_MACOS=true
fi
if [[ -n $MAS_IDS ]] && ask "Install Xcode from the App Store (~15 GB, you must be signed in to the App Store)?" y; then
  INSTALL_XCODE=true
fi

note "your password is needed once, for Homebrew, apps and macOS settings"
sudo -v
# Keep sudo alive until the script ends, so nothing stops to ask again
(
  trap - ERR
  set +e
  while kill -0 "$$" 2>/dev/null; do
    sudo -n true 2>/dev/null
    sleep 50
  done
) &
SUDO_KEEPALIVE=$!
trap 'kill "$SUDO_KEEPALIVE" 2>/dev/null || true' EXIT

# --- Steps ------------------------------------------------------------------------

step "SSH key"
if [[ -f $SSH_KEY ]]; then
  ok "~/.ssh/id_ed25519 already exists"
elif $CREATE_SSH_KEY; then
  mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
  note "choose a passphrase; the macOS Keychain will remember it"
  ssh-keygen -q -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY"
  ok "created ~/.ssh/id_ed25519"
else
  skip_step "no key created (you answered no)"
fi
if [[ -f $SSH_KEY ]]; then
  if ssh-add --apple-use-keychain "$SSH_KEY" >/dev/null; then
    ok "key added to the ssh agent and the Keychain"
  else
    warn "could not add the key; run: ssh-add --apple-use-keychain ~/.ssh/id_ed25519"
  fi
fi

step "Homebrew"
if command -v brew >/dev/null 2>&1 || [[ -x /opt/homebrew/bin/brew ]]; then
  ok "already installed"
else
  note "installing Homebrew and the Xcode Command Line Tools (git, compilers)"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ok "installed"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

step "Apps and CLIs (Brewfile)"
note "the longest step; Homebrew prints its own progress below"
mas_skip=""
if ! $INSTALL_XCODE; then
  mas_skip=$MAS_IDS
  [[ -n $MAS_IDS ]] && note "skipping App Store apps (Xcode), as you chose"
fi
# A single failing entry shouldn't stop the rest of the setup
if HOMEBREW_BUNDLE_MAS_SKIP="$mas_skip" brew bundle --file="$DOTFILES/Brewfile"; then
  ok "everything in the Brewfile is installed"
else
  warn "some Brewfile entries failed (see above); fix them and run: brew bundle --file=$DOTFILES/Brewfile"
fi

step "Config files"
# A ~/.gitconfig (e.g. from v1 of this repo) would override ~/.config/git/config
if [[ -L "$HOME/.gitconfig" ]]; then
  rm "$HOME/.gitconfig"
  ok "removed the old ~/.gitconfig symlink"
elif [[ -e "$HOME/.gitconfig" ]]; then
  warn "~/.gitconfig overrides ~/.config/git/config; merge it into git/config and delete it"
fi
link zsh/.zprofile .zprofile
link zsh/.zshrc .zshrc
link git/config .config/git/config
link git/.gitignore_global .gitignore_global
link mise/config.toml .config/mise/config.toml
link starship/starship.toml .config/starship.toml
link ssh/config .ssh/config
chmod 700 "$HOME/.ssh"
seed npm/.npmrc .npmrc
seed aws/config .aws/config
seed aws/credentials .aws/credentials
chmod 700 "$HOME/.aws"
chmod 600 "$HOME/.aws/credentials"
mkdir -p "$HOME/code/dev"
ok "~/code/dev"

step "VS Code"
link vscode/settings.json "Library/Application Support/Code/User/settings.json"
if ! command -v code >/dev/null 2>&1; then
  warn "the code command was not found; extensions not installed"
elif ! command -v jq >/dev/null 2>&1; then
  warn "jq not found (it comes from the Brewfile); extensions not installed"
else
  have=$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')
  added=0 present=0
  while IFS= read -r ext; do
    if grep -qxF "$ext" <<<"$have"; then
      present=$((present + 1))
    elif code --install-extension "$ext" >/dev/null 2>&1; then
      added=$((added + 1))
      ok "$ext"
    else
      warn "could not install the extension $ext"
    fi
  done < <(jq -r '.recommendations[] | ascii_downcase' "$DOTFILES/vscode/extensions.json")
  ok "extensions: $added installed, $present already there"
fi

step "Runtimes (mise)"
if (cd "$HOME" && mise install); then
  ok "$(cd "$HOME" && mise ls --current 2>/dev/null | awk '{print $1, $2}' | paste -sd ',' - | sed 's/,/, /g')"
else
  warn "mise install failed; run it again with: mise install"
fi

step "macOS preferences"
if $APPLY_MACOS; then
  bash "$DOTFILES/macos.sh"
  if fdesetup status 2>/dev/null | grep -q "On"; then
    ok "FileVault is on"
  else
    warn "FileVault is off: System Settings → Privacy & Security → FileVault"
  fi
else
  skip_step "skipped (you answered no)"
fi

step "Xcode"
xcode=/Applications/Xcode.app
if [[ -d "$xcode" ]]; then
  # CocoaPods and React Native builds need the command line tools to point at Xcode
  if [[ "$(xcode-select -p 2>/dev/null)" != "$xcode/Contents/Developer" ]]; then
    sudo xcode-select -s "$xcode/Contents/Developer"
  fi
  ok "command line tools point to Xcode"
  sudo xcodebuild -license accept
  ok "license accepted"
  sudo xcodebuild -runFirstLaunch >/dev/null
  ok "system components installed"
  note "iOS simulator (~8 GB), when you need it: xcodebuild -downloadPlatform iOS"
elif $INSTALL_XCODE; then
  warn "Xcode is not installed yet: sign in to the App Store and run install.sh again"
else
  skip_step "skipped (you answered no)"
fi

print_summary
printf '\n%sDone.%s Next: docs/workflow.md → "After install"\n' "$BOLD" "$RESET"
