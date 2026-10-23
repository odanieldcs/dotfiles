# Interactive shell. No framework: the Oh My Zsh behaviors worth keeping are
# reproduced below (history, completion menu, ↑/↓ prefix search).

# --- History -------------------------------------------------------------------
HISTFILE=$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY        # shared across tabs, written as you type
setopt EXTENDED_HISTORY     # timestamps
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE    # a leading space keeps a command (e.g. with a token) out of history
setopt HIST_VERIFY          # show !! / !$ expansions before running them

# --- Navigation ----------------------------------------------------------------
setopt AUTO_CD              # type a folder name to cd into it
# `cd my-project` works from anywhere if it lives in ~/code/dev
cdpath=(. $HOME/code/dev)

# --- Tools ---------------------------------------------------------------------
(( $+commands[mise] )) && eval "$(mise activate zsh)"
(( $+commands[starship] )) && eval "$(starship init zsh)" # config: ~/.config/starship.toml

# --- Aliases -------------------------------------------------------------------
alias ll='ls -lAh'
alias reload='exec zsh'
killport() { lsof -ti "tcp:$1" | xargs kill; }

# --- Machine-specific (not versioned): secrets, extra aliases ------------------
[[ -f $HOME/.zshrc.local ]] && source $HOME/.zshrc.local

# --- Line editor ---------------------------------------------------------------
# Warp replaces zsh's line editor with its own completions, suggestions and
# history search; these settings and plugins are unsupported there.
if [[ $TERM_PROGRAM != "WarpTerminal" && -n $HOMEBREW_PREFIX ]]; then
  fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)
  autoload -Uz compinit && compinit

  # Completion menu you can walk with the arrows; case-insensitive and substring
  # matching (same rules as Oh My Zsh)
  zstyle ':completion:*' menu select
  zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'

  # ↑/↓ walk only through history entries that start with what is already typed
  autoload -U up-line-or-beginning-search down-line-or-beginning-search
  zle -N up-line-or-beginning-search
  zle -N down-line-or-beginning-search
  bindkey '^[[A' up-line-or-beginning-search
  bindkey '^[OA' up-line-or-beginning-search
  bindkey '^[[B' down-line-or-beginning-search
  bindkey '^[OB' down-line-or-beginning-search

  (( $+commands[fzf] )) && source <(fzf --zsh)

  plugins=$HOMEBREW_PREFIX/share
  [[ -r $plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
    source $plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
  # must be sourced last
  [[ -r $plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
    source $plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  unset plugins
fi
