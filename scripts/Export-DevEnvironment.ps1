[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot),
    [switch]$SkipVSCode,
    [switch]$SkipPowerShell,
    [switch]$SkipBash,
    [switch]$SkipStarship,
    [string]$BashRcPath = (Join-Path $HOME '.bashrc'),
    [string]$StarshipConfigPath = (Join-Path $HOME '.config\starship.toml')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

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

$resolvedRepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path

if (-not $SkipVSCode) {
    $settingsSource = Join-Path $env:APPDATA 'Code\User\settings.json'
    if (-not (Test-Path -LiteralPath $settingsSource)) {
        throw "VS Code settings file not found: $settingsSource"
    }

    $settingsTarget = Join-Path $resolvedRepoRoot 'vscode\settings.json'
    Ensure-ParentDirectory -Path $settingsTarget

    if ($PSCmdlet.ShouldProcess($settingsTarget, "Export VS Code settings from $settingsSource")) {
        Copy-Item -LiteralPath $settingsSource -Destination $settingsTarget -Force
        Write-Host "Exported VS Code settings to $settingsTarget"
    }

    $codeCommand = Get-Command -Name code -ErrorAction SilentlyContinue
    if (-not $codeCommand) {
        throw "VS Code CLI 'code' was not found. Install the shell command before exporting extensions."
    }

    $extensionsTarget = Join-Path $resolvedRepoRoot 'vscode\extensions.txt'
    Ensure-ParentDirectory -Path $extensionsTarget

    if ($PSCmdlet.ShouldProcess($extensionsTarget, 'Export VS Code extensions list')) {
        & $codeCommand.Source --list-extensions | Set-Content -LiteralPath $extensionsTarget
        Write-Host "Exported VS Code extensions to $extensionsTarget"
    }
}

if (-not $SkipPowerShell) {
    $profileSource = $PROFILE.CurrentUserCurrentHost
    $profileTarget = Join-Path $resolvedRepoRoot 'powershell\Microsoft.PowerShell_profile.ps1'
    Ensure-ParentDirectory -Path $profileTarget

    if (Test-Path -LiteralPath $profileSource) {
        if ($PSCmdlet.ShouldProcess($profileTarget, "Export PowerShell profile from $profileSource")) {
            Copy-Item -LiteralPath $profileSource -Destination $profileTarget -Force
            Write-Host "Exported PowerShell profile to $profileTarget"
        }
    }
    else {
        Write-Host "PowerShell profile was not found at $profileSource; nothing was exported."
    }
}

if (-not $SkipBash) {
    $bashTarget = Join-Path $resolvedRepoRoot 'bash\.bashrc'
    Ensure-ParentDirectory -Path $bashTarget

    if (Test-Path -LiteralPath $BashRcPath) {
        if ($PSCmdlet.ShouldProcess($bashTarget, "Export Bash profile from $BashRcPath")) {
            Copy-Item -LiteralPath $BashRcPath -Destination $bashTarget -Force
            Write-Host "Exported Bash profile to $bashTarget"
        }
    }
    else {
        Write-Host "Bash profile was not found at $BashRcPath; nothing was exported."
    }
}

if (-not $SkipStarship) {
    $starshipTarget = Join-Path $resolvedRepoRoot 'starship\starship.toml'
    Ensure-ParentDirectory -Path $starshipTarget

    if (Test-Path -LiteralPath $StarshipConfigPath) {
        if ($PSCmdlet.ShouldProcess($starshipTarget, "Export Starship config from $StarshipConfigPath")) {
            Copy-Item -LiteralPath $StarshipConfigPath -Destination $starshipTarget -Force
            Write-Host "Exported Starship config to $starshipTarget"
        }
    }
    else {
        Write-Host "Starship config was not found at $StarshipConfigPath; nothing was exported."
    }
}
