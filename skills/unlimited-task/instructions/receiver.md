# Receiver ループ指示

あなたは unlimited-task の **receiver** です。sender が生成したタスクを取得し、実行し、レポートを作成する役割です。

## 安全制約（厳守）

### 禁止操作
- `git push`, `git push --force` — コードのプッシュは一切禁止
- 外部サービスへの送信（API コール、メール、Slack 等）
- 認証情報の操作（.env, credentials, secrets 等）
- ファイル削除（done/ への mv は可、rm は不可）
- `.unlimited-task/` 外の設定ファイル変更

### 許可範囲
- ファイルの作成・編集
- テスト実行（`npm test`, `cargo test` 等）
- ビルド（`npm run build`, `cargo build` 等）
- lint / format チェック
- 新規ドキュメントは config.yaml の `receiver.drafts_dir` 配下のみ
- 既存コードの編集は可

### 暴走停止
- `.unlimited-task/STOP` ファイルが存在したら**即座に**ループ停止し、ユーザーに報告

## ループ手順

### 1. 初期化・復帰チェック

1. `.unlimited-task/STOP` の存在チェック → あれば停止
2. `.unlimited-task/config.yaml` を読み込む
3. `.unlimited-task/receiver-state.yaml` を読み込む
4. `current_task` が設定されている場合:
   - そのファイルが `acquired/` に存在すれば途中から再開
   - 存在しなければ `current_task` をクリアして次のタスクへ

### 2. acquired タイムアウトチェック

`acquired/` 内の全ファイルについて:
- receiver-state.yaml の `acquired_at` と現在時刻を比較
- `acquired_timeout_seconds`（デフォルト 3600 秒）を超えていれば `instructions/` に戻す
- ログに警告を記録

### 3. タスク選択

1. `instructions/` 内のファイルを確認
2. ファイルがなければ `sleep_seconds` 秒待機してステップ1に戻る
3. `category_balance` が true の場合:
   - receiver-state.yaml の `last_category` を確認
   - 異なるカテゴリを優先的に選択
   - 全カテゴリが空なら任意のカテゴリから選択
4. ファイル名のタイムスタンプが古い順に選択（FIFO）

### 4. タスク取得

1. receiver-state.yaml に `current_task` と `acquired_at` を記録（アトミック書き込み）
2. 選択したファイルを `acquired/{category}/` に移動（`mv` コマンド）
   - mv はアトミック操作なので sender との競合なし

### 5. タスク実行

1. タスクファイルの指示を読み込む
2. 指示に従ってタスクを実行
   - 新規ドキュメントは `{drafts_dir}/` に配置
   - コードは適切な場所に配置
   - テスト・ビルドが指示に含まれていれば実行
3. エラーが発生した場合:
   - タスクファイルを `failed/{category}/` に移動
   - `report/{category}/{ファイル名}-failed.md` に失敗レポートを作成
   - receiver-state.yaml の `current_task` をクリア
   - 次のタスクへ進む（1件の失敗でループ全体を止めない）

### 6. 完了処理

1. タスクファイルを `done/{category}/` に移動
2. `report/{category}/{ファイル名}-report.md` にレポートを作成:
   ```markdown
   # レポート: {タスクタイトル}

   ## 実行日時
   {ISO8601 タイムスタンプ}

   ## 実行内容
   {何をしたかの要約}

   ## 成果物
   - {作成・変更したファイルのリスト}

   ## 備考
   {特記事項があれば}
   ```
3. receiver-state.yaml をアトミックに更新:
   ```yaml
   role: receiver
   status: active
   total_completed: {累計完了数}
   last_completed_at: "{ISO8601タイムスタンプ}"
   last_category: {今回のカテゴリ}
   current_task: null
   acquired_at: null
   ```

### 7. スリープ

`sleep_seconds` 秒待機。その後ステップ1に戻る。

## アトミック書き込みパターン

state ファイルの更新は必ず以下のパターンで行う:

1. 新しい内容を `{file}.tmp` に書く
2. `mv {file}.tmp {file}` でアトミックに置換

## auto-compact 復帰

compact 後にこのファイルが再読み込みされる。以下から復帰:
- receiver-state.yaml の `current_task` → 作業中タスクの継続
- receiver-state.yaml の `last_category` → カテゴリバランスの維持
- acquired/ / done/ / failed/ / instructions/ のファイル状態が ground truth
