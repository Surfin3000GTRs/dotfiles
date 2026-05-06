[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot),
    [switch]$SkipVSCode,
    [switch]$SkipGit,
    [switch]$SkipPowerShell,
    [switch]$SkipBash,
    [switch]$SkipStarship,
    [string]$BashRcPath = (Join-Path $HOME '.bashrc'),
    [string]$StarshipConfigPath = (Join-Path $HOME '.config\starship.toml')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Backup-File {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }

    $backupPath = '{0}.{1}.bak' -f $Path, (Get-Date -Format 'yyyyMMddHHmmss')
    Copy-Item -LiteralPath $Path -Destination $backupPath -Force
    return $backupPath
}

function Ensure-ParentDirectory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
}

function Get-VSCodeCliPath {
    $codeCommand = Get-Command -Name 'code.cmd' -ErrorAction SilentlyContinue
    if ($codeCommand) {
        return $codeCommand.Path
    }

    $fallbackPath = Join-Path $env:LOCALAPPDATA 'Programs\Microsoft VS Code\bin\code.cmd'
    if (Test-Path -LiteralPath $fallbackPath) {
        return $fallbackPath
    }

    throw "VS Code CLI 'code.cmd' was not found. Install the shell command or rerun with -SkipVSCode."
}

$resolvedRepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path

if (-not $SkipVSCode) {
    $settingsSource = Join-Path $resolvedRepoRoot 'vscode\settings.json'
    $extensionsSource = Join-Path $resolvedRepoRoot 'vscode\extensions.txt'

    if (-not (Test-Path -LiteralPath $settingsSource)) {
        throw "VS Code settings file not found: $settingsSource"
    }

    $settingsTarget = Join-Path $env:APPDATA 'Code\User\settings.json'
    Ensure-ParentDirectory -Path $settingsTarget

    if ($PSCmdlet.ShouldProcess($settingsTarget, "Copy VS Code settings from $settingsSource")) {
        $backupPath = Backup-File -Path $settingsTarget
        if ($backupPath) {
            Write-Host "Backed up VS Code settings to $backupPath"
        }
        Copy-Item -LiteralPath $settingsSource -Destination $settingsTarget -Force
        Write-Host "Applied VS Code settings to $settingsTarget"
    }

    if (Test-Path -LiteralPath $extensionsSource) {
        $codeCommandPath = Get-VSCodeCliPath

        $extensions = Get-Content -LiteralPath $extensionsSource |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_ }

        foreach ($extension in $extensions) {
            if ($PSCmdlet.ShouldProcess($extension, 'Install VS Code extension')) {
                & $codeCommandPath --install-extension $extension --force
            }
        }
    }
}

if (-not $SkipGit) {
    $gitCommand = Get-Command -Name git -ErrorAction SilentlyContinue
    if (-not $gitCommand) {
        throw "Git command was not found. Rerun with -SkipGit if you only want other settings."
    }

    $gitConfigSource = Join-Path $resolvedRepoRoot 'git\.gitconfig'
    if (-not (Test-Path -LiteralPath $gitConfigSource)) {
        throw "Git config file not found: $gitConfigSource"
    }

    $resolvedGitConfig = (Resolve-Path -LiteralPath $gitConfigSource).Path
    $currentIncludes = @(& $gitCommand.Source config --global --get-all include.path 2>$null)

    if ($currentIncludes -contains $resolvedGitConfig) {
        Write-Host "Git include.path already contains $resolvedGitConfig"
    }
    elseif ($PSCmdlet.ShouldProcess($resolvedGitConfig, 'Add repo Git config to global include.path')) {
        & $gitCommand.Source config --global --add include.path $resolvedGitConfig
        Write-Host "Added Git include.path -> $resolvedGitConfig"
    }
}

if (-not $SkipPowerShell) {
    $profileSource = Join-Path $resolvedRepoRoot 'powershell\Microsoft.PowerShell_profile.ps1'
    if (-not (Test-Path -LiteralPath $profileSource)) {
        throw "PowerShell profile source not found: $profileSource"
    }

    $profileTarget = $PROFILE.CurrentUserCurrentHost
    Ensure-ParentDirectory -Path $profileTarget

    if ($PSCmdlet.ShouldProcess($profileTarget, "Copy PowerShell profile from $profileSource")) {
        $backupPath = Backup-File -Path $profileTarget
        if ($backupPath) {
            Write-Host "Backed up PowerShell profile to $backupPath"
        }
        Copy-Item -LiteralPath $profileSource -Destination $profileTarget -Force
        Write-Host "Applied PowerShell profile to $profileTarget"
    }
}

if (-not $SkipBash) {
    $bashSource = Join-Path $resolvedRepoRoot 'bash\.bashrc'
    if (-not (Test-Path -LiteralPath $bashSource)) {
        throw "Bash profile source not found: $bashSource"
    }

    Ensure-ParentDirectory -Path $BashRcPath

    if ($PSCmdlet.ShouldProcess($BashRcPath, "Copy Bash profile from $bashSource")) {
        $backupPath = Backup-File -Path $BashRcPath
        if ($backupPath) {
            Write-Host "Backed up Bash profile to $backupPath"
        }
        Copy-Item -LiteralPath $bashSource -Destination $BashRcPath -Force
        Write-Host "Applied Bash profile to $BashRcPath"
    }
}

if (-not $SkipStarship) {
    $starshipSource = Join-Path $resolvedRepoRoot 'starship\starship.toml'
    if (-not (Test-Path -LiteralPath $starshipSource)) {
        throw "Starship config source not found: $starshipSource"
    }

    Ensure-ParentDirectory -Path $StarshipConfigPath

    if ($PSCmdlet.ShouldProcess($StarshipConfigPath, "Copy Starship config from $starshipSource")) {
        $backupPath = Backup-File -Path $StarshipConfigPath
        if ($backupPath) {
            Write-Host "Backed up Starship config to $backupPath"
        }
        Copy-Item -LiteralPath $starshipSource -Destination $StarshipConfigPath -Force
        Write-Host "Applied Starship config to $StarshipConfigPath"
    }
}
