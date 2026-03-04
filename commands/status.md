---
description: unlimited-task の進捗サマリを表示
allowed-tools: ["Bash", "Read", "Glob", "Skill"]
---

# unlimited-task:status

**FIRST**: Skill ツールで `unlimited-task` スキルをロードし、state 仕様を理解すること。

## 1. .unlimited-task/ の存在確認

`.unlimited-task/` を探す。見つからない場合:
```
.unlimited-task/ が見つかりません。
まず /unlimited-task:start を実行してください。
```

## 2. 各ディレクトリのファイル数をカウント

カテゴリ（engineering, research, fun）ごとに:

| ディレクトリ | 意味 |
|---|---|
| `instructions/{category}/` | 未着手 |
| `acquired/{category}/` | 作業中 |
| `done/{category}/` | 完了 |
| `failed/{category}/` | 失敗 |
| `report/{category}/` | レポート |

## 3. state ファイルの確認

sender-state.yaml の `last_generated_at`、receiver-state.yaml の `last_completed_at` から最終活動時刻を表示。

## 4. タイムアウト警告

config.yaml の `receiver.acquired_timeout_seconds` を読み、acquired/ 内でタイムアウトを超えたタスクを警告。

## 5. STOP ファイルの確認

`.unlimited-task/STOP` があれば停止中と表示。

## 6. テーブル形式で表示

```
=== unlimited-task 進捗サマリ ===

カテゴリ         未着手  作業中  完了  失敗  レポート
engineering        3       1      12     0      12
research           1       0       5     1       4
fun                2       0       8     0       8
---------------------------------------------------
合計               6       1      25     1      24

sender   最終活動: 2026-03-04 12:34:56  生成数: 42  状態: active
receiver 最終活動: 2026-03-04 12:34:50  完了数: 38  状態: active

[警告] acquired/engineering/task-001.md はタイムアウト（3600秒）を超えています
[停止中] .unlimited-task/STOP が存在します
```
