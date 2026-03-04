---
name: sender
description: sender ループを開始（タスク生成）
---

# unlimited-task:sender

以下の手順を実行すること。

## 1. sender 指示ファイルを読み込む

この SKILL.md は `skills/sender/SKILL.md` に存在する。
プラグイン内の共有リソースとして `shared/instructions/sender.md` がある。

パス: `{SKILL_DIR}/../../shared/instructions/sender.md`

このファイルを読み込むこと。

## 2. テンプレートの場所

sender がお題を生成する際に参照するテンプレートは以下にある:

- `{SKILL_DIR}/../../shared/templates/instruction-engineering.md`
- `{SKILL_DIR}/../../shared/templates/instruction-research.md`
- `{SKILL_DIR}/../../shared/templates/instruction-fun.md`

## 3. sender.md の指示に従う

読み込んだ sender.md の内容に従って sender ループを開始する。
