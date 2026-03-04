# claude-plugin-unlimited-task

sender/receiver パターンで Claude Code にタスクを自律的に生成・消化させる Claude Code プラグイン。

## 概要

2つの Claude プロセス（sender / receiver）を別ターミナルで起動し、ファイルシステムを介してタスクの生成→消化→レポート作成を自動で回します。

- **sender**: プロジェクトのコンテキストを理解し、engineering / research / fun カテゴリのタスクを生成
- **receiver**: 生成されたタスクを取得・実行し、レポートを作成

## インストール

```bash
claude plugin marketplace add kawaz/claude-plugin-unlimited-task
claude plugin install unlimited-task@claude-plugin-unlimited-task
```

## 使い方

### 初期化

```bash
# プロジェクトのリポジトリ内で実行
/unlimited-task:start
```

ワークスペースと `.unlimited-task/` ディレクトリが作成されます。

### sender / receiver の起動

`start` が案内するコマンドを別々のターミナルで実行:

```bash
# ターミナル1: sender（タスク生成）
(cd {workspace_path} && claude /unlimited-task:sender)

# ターミナル2: receiver（タスク消化）
(cd {workspace_path} && claude /unlimited-task:receiver)
```

### 進捗確認

```bash
/unlimited-task:status
```

### 設定変更

```bash
/unlimited-task:config
```

### 緊急停止

```bash
touch {workspace_path}/.unlimited-task/STOP
```

## ワークスペース構成

```
.unlimited-task/
  config.yaml              # ユーザー設定
  sender-state.yaml        # sender の永続状態
  receiver-state.yaml      # receiver の永続状態
  STOP                     # 存在すればループ停止
  instructions/{category}/ # 未着手タスク
  acquired/{category}/     # 作業中タスク
  done/{category}/         # 完了タスク
  failed/{category}/       # 失敗タスク
  report/{category}/       # レポート
```

## 設定

`.unlimited-task/config.yaml` で以下を調整可能:

| 設定 | デフォルト | 説明 |
|------|-----------|------|
| `sender.batch_size` | 3 | 1バッチあたりの生成数 |
| `sender.sleep_seconds` | 540 | バッチ間の休憩（秒） |
| `sender.max_instructions` | 100 | 生成上限 |
| `sender.guidance` | "" | お題の方向性ガイダンス |
| `receiver.sleep_seconds` | 300 | タスク間の休憩（秒） |
| `receiver.category_balance` | true | カテゴリバランス |
| `receiver.drafts_dir` | "docs/drafts" | ドキュメント配置先 |
| `receiver.acquired_timeout_seconds` | 3600 | タイムアウト（秒） |

## 安全性

- receiver は `git push` や外部サービスへの送信を行いません
- sender はファイル生成のみで、コード実行は行いません
- `STOP` ファイルによる緊急停止が可能です
- Claude の組み込みセキュリティは維持されます

## ライセンス

MIT License
