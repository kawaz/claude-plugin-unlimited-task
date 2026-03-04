---
name: check-version-bump
enabled: true
event: bash
pattern: (git|jj\s+git)\s+push
---

**push前に以下を確認してください。**

プラグイン機能（skills, hooks, commands など）を修正した場合:

1. `.claude-plugin/plugin.json` と `.claude-plugin/marketplace.json` の version は同期更新済みですか？
   - 未更新なら先にバージョンを上げてコミットしてください
2. `claude plugin validate .` を実行して検証に通りましたか？
   - 未実行なら実行して問題がないことを確認してください

プラグイン機能に変更がない場合はそのままpushしてOK
