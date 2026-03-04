---
name: start
description: unlimited-task ワークスペースを初期化し、sender/receiver の起動コマンドを案内
---

# unlimited-task:start

以下の手順を順番に実行すること。

## 1. リポジトリルートの特定

現在のワーキングディレクトリからリポジトリの親ディレクトリ（REPO_PARENT）を特定する。

- `.jj` が存在するリポジトリの場合:
  `jj workspace root` の出力を親ディレクトリのパスとする（つまり `jj workspace root` の1階層上）
- `.jj` がない git リポジトリの場合:
  `git rev-parse --git-common-dir` の出力から `.git` サフィックスを除いたパスを REPO_PARENT とする

## 2. unlimited-task ワークスペースの作成

REPO_PARENT 直下に `unlimited-task` という名前のワークスペースを作成する。

- `.jj` が存在するリポジトリの場合（jj workspace 方式）:
  repo 直下（REPO_PARENT）から `jj workspace add unlimited-task` を実行する。
  すでに存在する場合はスキップする。
- git のみのリポジトリの場合（git worktree 方式）:
  `git worktree add {REPO_PARENT}/unlimited-task` を実行する。
  すでに存在する場合はスキップする。

作成されたワークスペースのフルパスを `WORKSPACE_PATH` として記録する。

## 3. .unlimited-task/ ディレクトリ構造の作成

`{WORKSPACE_PATH}/.unlimited-task/` 以下に以下のディレクトリ・ファイルを作成する。
既存のファイルは上書きしないこと。

```
.unlimited-task/
  config.yaml              # プラグインの defaults/config.yaml からコピー
  sender-state.yaml        # 初期状態で作成
  receiver-state.yaml      # 初期状態で作成
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

`config.yaml` はプラグイン内の共有リソースからコピーする。
この SKILL.md は `skills/start/SKILL.md` に存在するため、`defaults/config.yaml` のパスは `{SKILL_DIR}/../../shared/defaults/config.yaml` となる。

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

## 4. config.yaml のプロジェクト名設定

`{WORKSPACE_PATH}/.unlimited-task/config.yaml` を読み込み、`project.name` フィールドをリポジトリ名から自動検出して設定する。
リポジトリ名は REPO_PARENT のディレクトリ名（パスの最後の要素）を使用する。

## 5. ユーザーへの案内

以下の情報をユーザーに表示すること。

```
unlimited-task の初期化が完了しました。

ワークスペース: {WORKSPACE_PATH}

次のステップ:
  別ターミナルで sender を起動:
    (cd {WORKSPACE_PATH} && claude /unlimited-task:sender)

  別ターミナルで receiver を起動:
    (cd {WORKSPACE_PATH} && claude /unlimited-task:receiver)

管理コマンド:
  設定変更:  /unlimited-task:config
  進捗確認:  /unlimited-task:status
  緊急停止:  touch {WORKSPACE_PATH}/.unlimited-task/STOP
```
