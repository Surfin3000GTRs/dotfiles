# Managed by dotfiles - source: repo/bash/.bashrc
# Backups are created by the install scripts when linking or copying.

# Starship prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

# History
HISTSIZE=50000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend cmdhist checkwinsize
PROMPT_COMMAND='history -a; history -n'

# Bash options
shopt -s autocd globstar

# Completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi

if [ -f /mingw64/share/git/completion/git-completion.bash ]; then
  . /mingw64/share/git/completion/git-completion.bash
fi

# Aliases
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

# Helpers
mkcd() { mkdir -p "$1" && cd "$1"; }
croot() { cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"; }
openhere() { explorer.exe .; }
winpath() { cygpath -w "${1:-$PWD}"; }
