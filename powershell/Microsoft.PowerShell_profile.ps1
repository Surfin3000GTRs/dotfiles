# Repo-managed PowerShell profile.
# Add shared shell customizations here.

if (Get-Command -Name 'starship' -ErrorAction SilentlyContinue) {
    Invoke-Expression (& starship init powershell)
}
