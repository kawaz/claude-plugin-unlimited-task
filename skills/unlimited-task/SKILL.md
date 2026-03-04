---
name: unlimited-task
description: sender/receiver パターンで無制限タスクを自律実行
arguments: サブコマンド (start|sender|receiver|status|config)
---

# unlimited-task

## サブコマンド分岐

`$ARGUMENTS` の最初の単語を読み取り、以下のサブコマンドに対応するセクションの指示に従うこと。
空白やその他の単語は無視し、最初の単語のみでサブコマンドを判定する。

- `start` → 「start: 初期化」セクションへ
- `sender` → 「sender: 送信ループ」セクションへ
- `receiver` → 「receiver: 受信ループ」セクションへ
- `status` → 「status: 進捗確認」セクションへ
- `config` → 「config: 設定管理」セクションへ
- 引数なし・不明なサブコマンド → 「ヘルプ表示」セクションへ

---

## ヘルプ表示

`$ARGUMENTS` が空または認識できないサブコマンドの場合、以下の内容を表示すること。

```
unlimited-task - sender/receiver パターンで無制限タスクを自律実行

サブコマンド:
  start      .unlimited-task/ を初期化し、sender/receiver の起動コマンドを案内
  sender     sender ループを開始（別ターミナルで実行）
  receiver   receiver ループを開始（別ターミナルで実行）
  status     進捗サマリを表示（未着手/作業中/完了/失敗/レポート件数）
  config     設定ファイルの表示・編集

使い方:
  /unlimited-task start      # まずここから始める
  /unlimited-task status     # 進捗確認
  /unlimited-task config     # 設定変更
```

---

## start: 初期化

以下の手順を順番に実行すること。

### 1. リポジトリルートの特定

現在のワーキングディレクトリからリポジトリの親ディレクトリ（REPO_PARENT）を特定する。

- `.jj` が存在するリポジトリの場合:
  `jj workspace root` の出力を親ディレクトリのパスとする（つまり `jj workspace root` の1階層上）
- `.jj` がない git リポジトリの場合:
  `git rev-parse --git-common-dir` の出力から `.git` サフィックスを除いたパスを REPO_PARENT とする

### 2. unlimited-task ワークスペースの作成

REPO_PARENT 直下に `unlimited-task` という名前のワークスペースを作成する。

- `.jj` が存在するリポジトリの場合（jj workspace 方式）:
  repo 直下（REPO_PARENT）から `jj workspace add unlimited-task` を実行する。
  すでに存在する場合はスキップする。
- git のみのリポジトリの場合（git worktree 方式）:
  `git worktree add {REPO_PARENT}/unlimited-task` を実行する。
  すでに存在する場合はスキップする。

作成されたワークスペースのフルパスを `WORKSPACE_PATH` として記録する。
（例: `/Users/kawaz/.local/share/repos/github.com/kawaz/myproject/unlimited-task`）

### 3. .unlimited-task/ ディレクトリ構造の作成

`{WORKSPACE_PATH}/.unlimited-task/` 以下に以下のディレクトリ・ファイルを作成する。
既存のファイルは上書きしないこと。

```
.unlimited-task/
  config.yaml              # プラグインの defaults/config.yaml からコピー
  sender-state.yaml        # 初期状態で作成
  receiver-state.yaml      # 初期状態で作成
  instructions/
    engineering/           # エンジニアリング系タスク指示ファイル置き場
    research/              # 調査・リサーチ系タスク指示ファイル置き場
    fun/                   # その他・趣味系タスク指示ファイル置き場
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

`config.yaml` は SKILL.md と同じプラグインディレクトリ内の `defaults/config.yaml` からコピーする。
SKILL.md の場所は `skills/unlimited-task/SKILL.md` であるため、`defaults/config.yaml` のフルパスは
SKILL.md があるディレクトリの親の `defaults/config.yaml` となる。

`sender-state.yaml` の初期内容:
```yaml
role: sender
status: idle
total_generated: 0
last_generated_at: null
last_batch_categories: []
```

`receiver-state.yaml` の初期内容:
```yaml
role: receiver
status: idle
total_completed: 0
last_completed_at: null
last_category: null
current_task: null
acquired_at: null
```

### 4. config.yaml のプロジェクト名設定

`{WORKSPACE_PATH}/.unlimited-task/config.yaml` を読み込み、`project.name` フィールドをリポジトリ名から自動検出して設定する。
リポジトリ名は REPO_PARENT のディレクトリ名（パスの最後の要素）を使用する。

### 5. ユーザーへの案内

以下の情報をユーザーに表示すること。

```
unlimited-task の初期化が完了しました。

ワークスペース: {WORKSPACE_PATH}

次のステップ:
  別ターミナルで sender を起動:
    (cd {WORKSPACE_PATH} && claude /unlimited-task sender)

  別ターミナルで receiver を起動:
    (cd {WORKSPACE_PATH} && claude /unlimited-task receiver)

管理コマンド:
  設定変更:  /unlimited-task config
  進捗確認:  /unlimited-task status
  緊急停止:  touch {WORKSPACE_PATH}/.unlimited-task/STOP

instructions/ ディレクトリにタスク指示ファイル（.md）を置くと、
sender が自動的に receiver に配信します。
カテゴリ別サブディレクトリ（engineering/research/fun）を使い分けてください。
```

---

## sender: 送信ループ

以下の手順を実行すること。

### 1. プラグインディレクトリ内の sender.md を読み込む

このファイル（SKILL.md）は `skills/unlimited-task/SKILL.md` に存在するため、
sender.md は同じディレクトリの `instructions/sender.md` にある。

SKILL.md のフルパスを基準として、同じディレクトリ内の `instructions/sender.md` を読み込むこと。
フルパス: SKILL.md があるディレクトリ + `/instructions/sender.md`

### 2. sender.md の指示に従う

読み込んだ `instructions/sender.md` の内容に従って sender ループを開始する。

---

## receiver: 受信ループ

以下の手順を実行すること。

### 1. プラグインディレクトリ内の receiver.md を読み込む

このファイル（SKILL.md）は `skills/unlimited-task/SKILL.md` に存在するため、
receiver.md は同じディレクトリの `instructions/receiver.md` にある。

SKILL.md のフルパスを基準として、同じディレクトリ内の `instructions/receiver.md` を読み込むこと。
フルパス: SKILL.md があるディレクトリ + `/instructions/receiver.md`

### 2. receiver.md の指示に従う

読み込んだ `instructions/receiver.md` の内容に従って receiver ループを開始する。

---

## status: 進捗確認

以下の手順を実行すること。

### 1. .unlimited-task/ の存在確認

現在のワーキングディレクトリまたはその親から `.unlimited-task/` ディレクトリを探す。

見つからない場合は以下を表示して終了する:
```
.unlimited-task/ が見つかりません。
まず /unlimited-task start を実行してください。
```

### 2. 各ディレクトリのファイル数をカウント

以下のディレクトリ内のファイル数をカテゴリ別にカウントする。

| ディレクトリ | 意味 |
|---|---|
| `instructions/{category}/` | 未着手タスク |
| `acquired/{category}/` | 作業中タスク |
| `done/{category}/` | 完了タスク |
| `failed/{category}/` | 失敗タスク |
| `report/{category}/` | レポート数 |

カテゴリは `engineering`, `research`, `fun` の3種類。

### 3. state ファイルの確認

`sender-state.yaml` と `receiver-state.yaml` を読み込み、
sender は `last_generated_at`、receiver は `last_completed_at` フィールドから最終活動時刻を取得して表示する。

### 4. タイムアウト警告

`config.yaml` の `receiver.acquired_timeout_seconds`（デフォルト 3600）を読み込み、
`acquired/` 内のファイルのタイムスタンプを確認する。
タイムアウトを超えているファイルがあれば警告として表示する。

### 5. STOP ファイルの確認

`.unlimited-task/STOP` が存在する場合、停止中であることを表示する。

### 6. 結果をテーブル形式で表示

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

---

## config: 設定管理

以下の手順を実行すること。

### 1. config.yaml の存在確認

`.unlimited-task/config.yaml` を探す。

見つからない場合は以下を表示して終了する:
```
.unlimited-task/config.yaml が見つかりません。
まず /unlimited-task start を実行してください。
```

### 2. 現在の設定を表示

`config.yaml` の内容を読み込んで表示する。

### 3. 変更したい項目をユーザーに確認

ユーザーに対して、変更したい設定項目と新しい値を尋ねる。

### 4. 変更を適用

ユーザーが指定した変更を `config.yaml` に書き込む。
変更後、更新された設定内容を表示して確認する。
