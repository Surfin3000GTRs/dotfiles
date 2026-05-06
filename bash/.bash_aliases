# Managed by dotfiles - source: repo/bash/.bash_aliases
# Backups are created by the install scripts when linking or copying.

alias ls='ls --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'
alias c='clear'

alias gst='git status -sb'
alias gaa='git add --all'
alias gcm='git commit -m'
alias gco='git switch'
alias gcb='git switch -c'
alias gpl='git pull --rebase'
alias gl='git log --oneline --graph --decorate -20'

mkcd() { mkdir -p "$1" && cd "$1"; }
croot() { cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"; }
openhere() { explorer.exe .; }
winpath() { cygpath -w "${1:-$PWD}"; }
