# my-vscode-setup

Windows の開発環境を Git でまとめて管理するためのリポジトリです。

| 対象 | 管理ファイル |
| --- | --- |
| VS Code 設定 | `vscode\settings.json` |
| VS Code 拡張機能 | `vscode\extensions.txt` |
| Git 設定 | `git\.gitconfig` |
| PowerShell プロファイル | `powershell\Microsoft.PowerShell_profile.ps1` |
| Bash 設定 | `bash\.bashrc`, `bash\.bash_aliases` |
| Starship 設定 | `starship\starship.toml` |

## ディレクトリ構成

```text
.
|-- bash
|   |-- .bash_aliases
|   `-- .bashrc
|-- git
|   `-- .gitconfig
|-- powershell
|   `-- Microsoft.PowerShell_profile.ps1
|-- scripts
|   |-- Apply-DevEnvironment.ps1
|   `-- Export-DevEnvironment.ps1
|-- starship
|   `-- starship.toml
`-- vscode
    |-- extensions.txt
    `-- settings.json
```

## 使い方

### 1. リポジトリ管理の設定をローカルへ適用する

```powershell
pwsh -File .\scripts\Apply-DevEnvironment.ps1
```

このスクリプトは次を行います。

- VS Code の `settings.json` を適用
- `extensions.txt` にある拡張機能をインストール
- Git の global config に `git\.gitconfig` を `include.path` として登録
- repo 管理の PowerShell プロファイルをユーザープロファイルへ反映
- repo 管理の Bash 設定を `$HOME\.bashrc` と `$HOME\.bash_aliases` へ反映
- repo 管理の Starship 設定を `$HOME\.config\starship.toml` へ反映

既存の `settings.json`、PowerShell プロファイル、Bash 設定、Starship 設定は、上書き前に `.bak` 付きでバックアップされます。

### 2. ローカル環境をリポジトリへエクスポートする

```powershell
pwsh -File .\scripts\Export-DevEnvironment.ps1
```

このスクリプトは次をリポジトリへ取り込みます。

- 現在の VS Code `settings.json`
- 現在インストール済みの VS Code 拡張機能一覧
- 現在の PowerShell プロファイル
- 現在の Bash 設定
- 現在の Bash alias / helper 設定
- 現在の Starship 設定

Git 設定は `git\.gitconfig` を直接編集して管理します。`Apply-DevEnvironment.ps1` はそのファイルを global Git config に読み込ませるだけです。

## オプション

一部だけ適用・エクスポートしたい場合は各スクリプトでスキップできます。

```powershell
pwsh -File .\scripts\Apply-DevEnvironment.ps1 -SkipGit
pwsh -File .\scripts\Export-DevEnvironment.ps1 -SkipPowerShell
pwsh -File .\scripts\Apply-DevEnvironment.ps1 -SkipBash -SkipStarship
```

適用先や取り込み元を変えたい場合は、`-BashRcPath`、`-BashAliasesPath`、`-StarshipConfigPath` で上書きできます。

## 運用メモ

- Git の共通設定は `git\.gitconfig` に追記する
- PowerShell の共通設定は `powershell\Microsoft.PowerShell_profile.ps1` に追記する
- Bash の共通設定は `bash\.bashrc` に追記する
- Bash の alias / helper は `bash\.bash_aliases` に追記する
- Starship の共通設定は `starship\starship.toml` に追記する
- VS Code の設定を更新したら `Export-DevEnvironment.ps1` で正本を更新する
