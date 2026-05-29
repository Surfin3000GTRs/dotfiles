# Managed by dotfiles - source: repo/bash/.bash_aliases
# Backups are created by the install scripts when linking or copying.

# File system aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'

# Git aliases
alias gst='git status -sb'
alias gaa='git add --all'
alias gcm='git commit -m'
alias gco='git switch'
alias gcb='git switch -c'
alias gpl='git pull --rebase'
alias gl='git log --oneline --graph --decorate -20'

# Utility functions - directory operations
mkcd() {
  mkdir -p "$1" && cd "$1"
}

croot() {
  cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
}

# Utility functions - Windows path operations
wopen() {
  explorer.exe "$(cygpath -w "${1:-$PWD}")"
}

winpath() {
  cygpath -w "${1:-$PWD}"
}
