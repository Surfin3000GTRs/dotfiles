# Copilot Instructions

## Repository purpose

This repository is the source of truth for a Windows development environment. The tracked files in `vscode\`, `git\`, `powershell\`, `bash\`, and `starship\` are the canonical configs, and the PowerShell scripts in `scripts\` synchronize those configs between the repo and the local machine.

## Commands

- Apply the repo-managed environment to the current machine:
  - `pwsh -File .\scripts\Apply-DevEnvironment.ps1`
- Export the current machine state back into the repo:
  - `pwsh -File .\scripts\Export-DevEnvironment.ps1`
- Safe dry run for script changes:
  - `pwsh -File .\scripts\Apply-DevEnvironment.ps1 -WhatIf`
  - `pwsh -File .\scripts\Export-DevEnvironment.ps1 -WhatIf`
- Narrow validation to one managed surface by combining `-WhatIf` with the existing skip flags. Example: VS Code only:
  - `pwsh -File .\scripts\Apply-DevEnvironment.ps1 -SkipGit -SkipPowerShell -SkipBash -SkipStarship -WhatIf`
- Override non-default shell config locations when needed:
  - `pwsh -File .\scripts\Apply-DevEnvironment.ps1 -BashRcPath <path> -StarshipConfigPath <path>`
  - `pwsh -File .\scripts\Export-DevEnvironment.ps1 -BashRcPath <path> -StarshipConfigPath <path>`

There is currently no dedicated build, lint, or automated test suite in this repository, so there is no single-test command. Use `-WhatIf` and the existing `-Skip*` switches for targeted validation.

## High-level architecture

- `scripts\Apply-DevEnvironment.ps1` is the repo-to-machine sync path. It resolves the repo root from the script location, ensures parent directories exist, backs up existing target files with timestamped `.bak` suffixes, then copies the tracked files into place.
- `scripts\Export-DevEnvironment.ps1` is the machine-to-repo sync path. It copies the current local VS Code, PowerShell, Bash, and Starship state back into the tracked files.
- Git is intentionally handled differently from the other managed surfaces: the repo keeps `git\.gitconfig` as a tracked include file, and apply registers it through global `include.path` instead of copying over the user's main Git config.
- VS Code management has two parts: `vscode\settings.json` is copied directly, and `vscode\extensions.txt` is treated as the declarative extension list that apply installs and export regenerates via the `code` CLI.
- The tracked config files themselves are intentionally simple. The scripts are the only automation layer; most repo changes should update either the tracked config files or those two sync scripts.

## Key conventions

- Treat the tracked files under `vscode\`, `git\`, `powershell\`, `bash\`, and `starship\` as the canonical source. Avoid adding alternate generated sources of truth.
- Preserve the one-way Git workflow: edit `git\.gitconfig` directly in the repo; do not add Git export logic unless the repository’s operating model changes.
- Follow the existing PowerShell script style when modifying or adding automation:
  - `[CmdletBinding(SupportsShouldProcess = $true)]`
  - `Set-StrictMode -Version Latest`
  - `$ErrorActionPreference = 'Stop'`
  - explicit `Test-Path` checks with `throw` on missing required inputs
  - small helper functions for shared file operations such as backup and parent-directory creation
- Keep destructive behavior guarded by `ShouldProcess` so `-WhatIf` remains useful.
- When extending scope, prefer the existing `-SkipVSCode`, `-SkipGit`, `-SkipPowerShell`, `-SkipBash`, `-SkipStarship`, `-BashRcPath`, and `-StarshipConfigPath` parameters instead of inventing parallel mechanisms.
- Repository documentation is currently written in Japanese, so keep README-level documentation updates aligned with that language and terminology.
