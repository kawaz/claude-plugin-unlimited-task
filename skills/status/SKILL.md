---
name: status
description: unlimited-task の進捗サマリを表示
---

# unlimited-task:status

以下の手順を実行すること。

## 1. .unlimited-task/ の存在確認

現在のワーキングディレクトリまたはその親から `.unlimited-task/` ディレクトリを探す。

見つからない場合は以下を表示して終了する:
```
.unlimited-task/ が見つかりません。
まず /unlimited-task:start を実行してください。
```

## 2. 各ディレクトリのファイル数をカウント

以下のディレクトリ内のファイル数をカテゴリ別にカウントする。

| ディレクトリ | 意味 |
|---|---|
| `instructions/{category}/` | 未着手タスク |
| `acquired/{category}/` | 作業中タスク |
| `done/{category}/` | 完了タスク |
| `failed/{category}/` | 失敗タスク |
| `report/{category}/` | レポート数 |

カテゴリは `engineering`, `research`, `fun` の3種類。

## 3. state ファイルの確認

`sender-state.yaml` と `receiver-state.yaml` を読み込み、
sender は `last_generated_at`、receiver は `last_completed_at` フィールドから最終活動時刻を取得して表示する。

## 4. タイムアウト警告

`config.yaml` の `receiver.acquired_timeout_seconds`（デフォルト 3600）を読み込み、
`acquired/` 内のファイルのタイムスタンプを確認する。
タイムアウトを超えているファイルがあれば警告として表示する。

## 5. STOP ファイルの確認

`.unlimited-task/STOP` が存在する場合、停止中であることを表示する。

## 6. 結果をテーブル形式で表示

以下のような形式で表示すること。

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
