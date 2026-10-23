# Everything installed on a new Mac. Apply with `brew bundle`.
# `brew bundle cleanup` lists what is installed but missing here (add --force to remove).
#
# Languages are NOT here: Homebrew installs mise, mise installs node/pnpm/python/go
# (see mise/config.toml), so each project can pin its own version.

# --- Core ---------------------------------------------------------------------
brew "git"                      # newer than the git bundled with Xcode CLT
brew "mas"                      # Mac App Store CLI, used by the `mas` entries below
brew "mise"                     # runtime version manager (replaces volta + direnv)

# --- Terminal & shell ----------------------------------------------------------
cask "warp"
brew "starship"                 # prompt
brew "zsh-autosuggestions"      # outside Warp only (Warp has its own)
brew "zsh-syntax-highlighting"  # outside Warp only
brew "fzf"                      # Ctrl-R fuzzy history, Ctrl-T file picker (outside Warp)

# --- Fonts (fonts without a cask go in fonts/) ---------------------------------
cask "font-fira-code"
cask "font-jetbrains-mono"
cask "font-jetbrains-mono-nerd-font" # icons for starship in VS Code/Cursor terminals

# --- Dev CLIs ------------------------------------------------------------------
brew "gh"                       # GitHub CLI
brew "git-delta"                # pager for git diff/log/show
brew "awscli"                   # defaults in aws/config
brew "jq"                       # JSON CLI processor
brew "ripgrep"                  # fast search (like `grep` but better)
brew "mkcert"                   # trusted local HTTPS certificates
brew "supabase"
cask "ngrok"

# --- iOS & React Native --------------------------------------------------------
mas "Xcode", id: 497799835      # ~15 GB; install.sh finishes its setup
brew "cocoapods"
brew "watchman"

# --- Editors -------------------------------------------------------------------
cask "visual-studio-code"       # settings in vscode/, shared with Cursor
cask "cursor"
cask "zed"

# --- AI coding -----------------------------------------------------------------
cask "claude-code"              # `claude` CLI
cask "claude"                   # desktop app
cask "superset"                 # terminal for running several agents
tap "stablyai/orca"             # AI agent orchestrator
cask "stablyai/orca/orca", trusted: true # Homebrew requires explicit trust for third-party taps

# --- Dev apps ------------------------------------------------------------------
cask "docker-desktop"
cask "tableplus"                # main GUI for DBs (Postgres, SQLite, Redis, etc.)
cask "bruno"                    # API client
cask "insomnia"                 # API client
cask "dbeaver-community"        # GUI for DBs (alternative to TablePlus)

# --- Apps ----------------------------------------------------------------------
cask "thebrowsercompany-dia"
cask "google-chrome"
cask "bitwarden"
cask "cleanshot"
cask "discord"
cask "figma"
cask "notion"
cask "obs"
cask "slack"
cask "spotify"
cask "zoom"

# --- VS Code extensions --------------------------------------------------------
# brew bundle installs these into VS Code; install.sh mirrors them into Cursor.
# On the old Mac: brew bundle dump --file=- | grep '^vscode'  → paste here
