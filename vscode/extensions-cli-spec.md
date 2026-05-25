# VS Code 拡張機能 CLI 管理 仕様

このドキュメントは `vscode/extensions.txt` と VS Code CLI (`code.cmd`) を使った拡張機能管理の仕様をまとめたものです。

---

## 1. 管理ファイル

| ファイル | 役割 |
| --- | --- |
| `vscode/extensions.txt` | インストール対象の拡張機能 ID を宣言するリスト |

### 1.1 `extensions.txt` のフォーマット

- 1 行 1 拡張機能 ID（例: `publisher.extension-name`）
- 空行・空白のみの行は無視される
- 各行の前後の空白文字はトリムして使用される
- 拡張機能 ID は VS Code の規約に従い小文字で記述する（例: `ms-ceintl.vscode-language-pack-ja`）

---

## 2. 適用（Apply）

`scripts/Apply-DevEnvironment.ps1` 実行時の拡張機能処理。

### 2.1 動作フロー

1. `vscode/extensions.txt` を読み込む
2. 各行をトリムし、空行を除外して拡張機能 ID のリストを作成
3. 各 ID に対して `code.cmd --install-extension <id> --force` を実行

### 2.2 `--force` の意味

既にインストール済みの同バージョンでも再インストールを強制する。べき等な適用を保証する。

### 2.3 スキップ条件

`-SkipVSCode` スイッチを指定した場合、`settings.json` の適用と拡張機能のインストールの両方がスキップされる。

### 2.4 スコープ外（非対応）

- `extensions.txt` から削除された拡張機能の**アンインストールは行わない**。
  リストから外しても、既存の拡張機能はローカル環境に残存する。

---

## 3. エクスポート（Export）

`scripts/Export-DevEnvironment.ps1` 実行時の拡張機能処理。

### 3.1 動作フロー

1. `code.cmd --list-extensions` を実行
2. 出力をそのまま `vscode/extensions.txt` に**上書き**保存

### 3.2 出力形式

- VS Code の `--list-extensions` が返す順序（通常アルファベット昇順）に依存する
- ソートや重複排除はスクリプト側では行わない

### 3.3 スキップ条件

`-SkipVSCode` スイッチを指定した場合、`settings.json` のエクスポートと拡張機能一覧のエクスポートの両方がスキップされる。

---

## 4. CLI 検出ロジック（`Get-VSCodeCliPath`）

Apply・Export の両スクリプトで共通して使用される関数。

| 優先度 | 検索先 |
| --- | --- |
| 1 | `Get-Command code.cmd`（PATH から検索） |
| 2 | `$LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd`（既定インストール先） |

どちらも見つからない場合はエラーをスローしてスクリプトを中断する。

---

## 5. 制約・前提

| 項目 | 内容 |
| --- | --- |
| 対応 OS | Windows のみ（`code.cmd` 依存） |
| VS Code のインストール | シェルコマンド (`code.cmd`) が PATH またはデフォルト場所に存在すること |
| 拡張機能の削除 | 自動削除は非対応。手動でアンインストールする必要がある |
| `-WhatIf` サポート | Apply/Export ともに `-WhatIf` を指定すると実際の CLI 呼び出しをスキップできる |

---

## 6. 運用フロー

```
┌─────────────────────────────────────────────────────────┐
│  リポジトリ                                              │
│  vscode/extensions.txt  ←──────── Export-DevEnvironment │
│         │                                                │
│         └──────────────────────→ Apply-DevEnvironment   │
│                                        │                 │
│                                  code.cmd --install      │
│                                  --install-extension     │
└─────────────────────────────────────────────────────────┘
```

1. **新しいマシンへの適用**: `Apply-DevEnvironment.ps1` を実行 → `extensions.txt` の全拡張機能がインストールされる
2. **現環境の保存**: `Export-DevEnvironment.ps1` を実行 → 現在インストール済みの拡張機能一覧が `extensions.txt` に書き込まれる
3. **拡張機能の追加**: `extensions.txt` に ID を手動で追記し、`Apply-DevEnvironment.ps1` を再実行
4. **拡張機能の削除**: `extensions.txt` から ID を削除し、ローカルでは手動アンインストール
