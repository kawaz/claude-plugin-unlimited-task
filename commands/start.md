---
description: unlimited-task ワークスペースを初期化し、sender/receiver の起動コマンドを案内
allowed-tools: ["Bash", "Read", "Write", "Glob", "Skill"]
---

# unlimited-task:start

**FIRST**: Skill ツールで `unlimited-task` スキルをロードし、ワークスペース構成・config 仕様・state 仕様を理解すること。

以下の手順を順番に実行する。

## 1. リポジトリルートの特定

現在のワーキングディレクトリからリポジトリの親ディレクトリ（REPO_PARENT）を特定する。

- `.jj` が存在するリポジトリの場合:
  `jj workspace root` の出力の1階層上を REPO_PARENT とする
- `.jj` がない git リポジトリの場合:
  `git rev-parse --git-common-dir` の出力から `.git` サフィックスを除いたパスを REPO_PARENT とする

## 2. unlimited-task ワークスペースの作成

REPO_PARENT 直下に `unlimited-task` ワークスペースを作成する。

- `.jj` が存在する場合: REPO_PARENT から `jj workspace add unlimited-task` を実行
- git のみの場合: `git worktree add {REPO_PARENT}/unlimited-task` を実行
- すでに存在する場合はスキップ

作成されたフルパスを WORKSPACE_PATH として記録する。

## 3. .unlimited-task/ ディレクトリ構造の作成

知識スキルで定義されたワークスペース構成に従い、`{WORKSPACE_PATH}/.unlimited-task/` を作成する。
既存ファイルは上書きしない。

config.yaml のデフォルト内容は知識スキルの「config.yaml 仕様」セクションを参照。
sender-state.yaml / receiver-state.yaml の初期内容は知識スキルの各仕様セクションを参照。

## 4. config.yaml のプロジェクト名設定

`project.name` を REPO_PARENT のディレクトリ名から自動検出して設定する。

## 5. ユーザーへの案内

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
