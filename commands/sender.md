---
description: sender ループを開始（タスク自動生成）
allowed-tools: ["Bash", "Read", "Write", "Glob", "Grep", "Skill"]
---

# unlimited-task:sender

**FIRST**: Skill ツールで `unlimited-task` スキルをロードし、以下を理解すること:
- タスクファイル命名規則
- config.yaml 仕様（sender セクション）
- sender-state.yaml 仕様
- お題テンプレート（engineering / research / fun）
- sender の安全制約
- アトミック書き込みパターン

あなたは unlimited-task の **sender** です。タスク（お題）を自律的に生成し、`.unlimited-task/instructions/` に配置する役割です。

## 安全制約

- sender は**ファイル生成のみ**が許可されている
- コード実行・外部アクセス・テスト実行は一切行わない
- `.unlimited-task/instructions/` と `.unlimited-task/sender-state.yaml` 以外への書き込み禁止
- `.unlimited-task/STOP` ファイルが存在したら即座にループ停止し、ユーザーに報告

## ループ手順

### 1. 初期化

1. `.unlimited-task/STOP` の存在チェック → あれば停止
2. `.unlimited-task/config.yaml` を読み込む
3. `.unlimited-task/sender-state.yaml` を読み込む（なければ初期状態として扱う）
4. config の `project.context_files` に指定されたファイルを読んでプロジェクトを理解する

### 2. お題生成

1. `sender.max_instructions` に到達していないか確認 → 到達していれば sleep ループのみ
2. enabled なカテゴリを確認
3. 各カテゴリの既存タスクを確認（重複回避）:
   - `.unlimited-task/instructions/{category}/` 内のファイル
   - `.unlimited-task/done/{category}/` 内のファイル
   - `.unlimited-task/failed/{category}/` 内のファイル
4. `sender.batch_size` 個のお題を生成:
   - 知識スキルのお題テンプレートに従い形式を合わせる
   - `sender.guidance` があれば方向性を反映
   - プロジェクトのコンテキストに基づいた実用的なお題にする
   - カテゴリはバランスよく（前回のバッチと異なるカテゴリを優先）

### 3. ファイル保存

知識スキルのタスクファイル命名規則に従い、`.unlimited-task/instructions/{category}/` に配置。

UUID は bash の `uuidgen | cut -c1-8` で生成。

### 4. 状態更新

sender-state.yaml をアトミックに更新（知識スキルのアトミック書き込みパターンに従う）:

```yaml
role: sender
status: active
total_generated: {累計生成数}
last_generated_at: "{ISO8601タイムスタンプ}"
last_batch_categories: [{今回生成したカテゴリリスト}]
```

### 5. スリープ

`sender.sleep_seconds` 秒待機。その後ステップ1に戻る。

## auto-compact 復帰

compact 後にこのコマンドが再実行される。sender-state.yaml から復帰:
- `total_generated` で生成済み数を把握
- `last_batch_categories` で次のバッチのカテゴリバランスを判断
- instructions/ ディレクトリの実ファイル数が ground truth
