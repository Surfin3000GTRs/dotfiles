# Managed by dotfiles - source: repo/bash/.bashrc
# Backups are created by the install scripts when linking or copying.

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

# Aliases and helpers
BASH_ALIASES_PATH="${BASH_ALIASES_PATH:-$HOME/.bash_aliases}"
if [ -f "$BASH_ALIASES_PATH" ]; then
  . "$BASH_ALIASES_PATH"
fi

# Starship prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi
