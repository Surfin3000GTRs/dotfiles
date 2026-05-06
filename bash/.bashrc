# Managed by dotfiles - source: repo/bash/.bashrc
# Backups are created by the install scripts when linking or copying.

# Starship prompt
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi
