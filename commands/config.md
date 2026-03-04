---
description: unlimited-task の設定ファイルを表示・編集
allowed-tools: ["Read", "Edit", "AskUserQuestion", "Skill"]
---

# unlimited-task:config

**FIRST**: Skill ツールで `unlimited-task` スキルをロードし、config.yaml 仕様を理解すること。

## 1. config.yaml の存在確認

`.unlimited-task/config.yaml` を探す。見つからない場合:
```
.unlimited-task/config.yaml が見つかりません。
まず /unlimited-task:start を実行してください。
```

## 2. 現在の設定を表示

config.yaml を読み込んで表示する。

## 3. 変更したい項目をユーザーに確認

AskUserQuestion でユーザーに変更したい設定項目と新しい値を尋ねる。

## 4. 変更を適用

指定された変更を config.yaml に書き込み、更新後の内容を表示して確認する。
