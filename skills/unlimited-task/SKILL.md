---
name: unlimited-task-knowledge
description: unlimited-task プラグインの共有知識（テンプレート・仕様・制約）
---

# unlimited-task 共有知識

各コマンドから Skill ツール経由でロードされる共有知識ベースです。

## ワークスペース構成

`/unlimited-task:start` が `.unlimited-task/` を初期化する際の構成:

```
.unlimited-task/
  config.yaml              # ユーザー設定
  sender-state.yaml        # sender の永続状態
  receiver-state.yaml      # receiver の永続状態
  STOP                     # 存在すればループ停止（緊急停止用）
  instructions/
    engineering/
    research/
    fun/
  acquired/
    engineering/
    research/
    fun/
  done/
    engineering/
    research/
    fun/
  failed/
    engineering/
    research/
    fun/
  report/
    engineering/
    research/
    fun/
```

## タスクファイル命名規則

```
{yyyymmddThhmmss}-{uuid8文字}-{kebab-case-title}.md
```

例: `20260304T023000-8d2f34c0-homebrew-formula-packaging.md`

- タイムスタンプ: 生成時刻（JST）
- UUID 8文字: 衝突回避
- タイトル: 英語 kebab-case

## config.yaml 仕様

```yaml
project:
  name: ""                        # 自動検出（git remote / ディレクトリ名）
  description: ""                 # プロジェクト概要
  context_files: []               # sender が読むべきファイル

categories:
  engineering:
    enabled: true
    description: "実装・テスト・設計タスク"
  research:
    enabled: true
    description: "調査・比較分析レポート"
  fun:
    enabled: true
    description: "ペルソナ討論・ブレスト・エンタメ系"

sender:
  batch_size: 3
  sleep_seconds: 540
  max_instructions: 100
  guidance: ""

receiver:
  sleep_seconds: 300
  category_balance: true
  drafts_dir: "docs/drafts"
  acquired_timeout_seconds: 3600
  max_retries: 0
  additional_context: ""
```

## sender-state.yaml 仕様

```yaml
role: sender
status: idle          # idle | active
total_generated: 0
last_generated_at: null
last_batch_categories: []
```

## receiver-state.yaml 仕様

```yaml
role: receiver
status: idle          # idle | active
total_completed: 0
last_completed_at: null
last_category: null
current_task: null    # 作業中タスクのパス
acquired_at: null     # 取得時刻
```

## タスク状態遷移

```
instructions/ → acquired/ → done/     （成功）
                          → failed/   （失敗）
```

## アトミック書き込みパターン

state ファイルの更新は必ず以下のパターンで行う:

1. 新しい内容を `{file}.tmp` に書く
2. `mv {file}.tmp {file}` でアトミックに置換

## 共通安全制約

### sender の制約
- ファイル生成のみ許可
- コード実行・外部アクセス・テスト実行は不可
- `.unlimited-task/instructions/` と `.unlimited-task/sender-state.yaml` 以外への書き込み禁止

### receiver の制約
- **禁止**: git push, 外部サービスへの送信, 認証情報の操作, rm によるファイル削除
- **許可**: ファイルの作成・編集, テスト実行, ビルド, lint/format
- 新規ドキュメントは `receiver.drafts_dir` 配下のみ

### 暴走停止
- `.unlimited-task/STOP` ファイルが存在したら即座にループ停止

## お題テンプレート

### engineering

```markdown
# {日本語タイトル}

## 指示
承認不要の完全オートモードで以下を行うこと。

## 概要
{プロジェクトコンテキストに基づく課題説明}

## 作業内容
1. {具体的な作業ステップ}

## 期待する成果物
- {成果物}

## 完了条件
- {検証可能な完了条件}

> **配置ルール**: この指示による新規ドキュメントは config.yaml の `receiver.drafts_dir` 配下に配置すること。
```

### research

```markdown
# {日本語タイトル}

## 指示
承認不要の完全オートモードで以下の調査・分析を行うこと。

## 概要
{調査の背景と目的}

## 調査対象
- {調査対象}

## 評価基準
| 基準 | 重要度 | 説明 |
|------|--------|------|
| {基準} | 高/中/低 | {説明} |

## 作業内容
1. {調査ステップ}

## 期待する成果物
- 調査レポート（比較表・推奨事項を含む）

> **配置ルール**: この指示による新規ドキュメントは config.yaml の `receiver.drafts_dir` 配下に配置すること。
```

### fun

```markdown
# {日本語タイトル}

## 指示
承認不要の完全オートモードで以下のディスカッションを行うこと。

## 概要
{テーマの背景}

## チーム構成（ペルソナ）
- **{ペルソナ}**: {役割・専門性}

## ディスカッションテーマ
{議論すべきテーマ・問い}

## 進行ルール
1. 各ペルソナが順番に意見を述べる
2. 他のペルソナの意見に対して反論・補足する
3. 最終的に合意点と残論点をまとめる

## 期待する成果物
- ディスカッションログ
- 結論・合意事項のサマリ

> **配置ルール**: この指示による新規ドキュメントは config.yaml の `receiver.drafts_dir` 配下に配置すること。
```

## auto-compact 復帰

sender/receiver は compact 後に state ファイルから復帰する:
- state ファイルに保存された永続状態を読み込む
- ディレクトリのファイル状態が ground truth
- SKILL.md（この知識スキル）は各コマンドから再ロードされる
