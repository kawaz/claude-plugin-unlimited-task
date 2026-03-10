# claude-plugin-unlimited-task

# プラグインバリデーション
validate:
    claude plugin validate .

# バージョン表示
version:
    @jq -r '.version' .claude-plugin/plugin.json

# push（バージョンチェック付き）
push:
    #!/usr/bin/env bash
    set -euo pipefail
    # plugin.json と marketplace.json のバージョン一致チェック
    plugin_ver=$(jq -r '.version' .claude-plugin/plugin.json)
    market_ver=$(jq -r '.metadata.version' .claude-plugin/marketplace.json)
    if [ "$plugin_ver" != "$market_ver" ]; then
        echo "ERROR: plugin.json ($plugin_ver) と marketplace.json ($market_ver) のバージョンが不一致です。" >&2
        exit 1
    fi
    # origin/HEAD との diff にプラグイン関連の変更があるかチェック
    diff_files=$(git diff origin/HEAD --name-only 2>/dev/null || true)
    if [ -n "$diff_files" ]; then
        has_version_files=$(echo "$diff_files" | grep -cE '^\.claude-plugin/(plugin|marketplace)\.json$' || true)
        if [ "$has_version_files" -eq 0 ]; then
            echo "ERROR: origin/HEAD との差分がありますがバージョンが更新されていません。" >&2
            echo "バージョンbump不要なら: just push-without-bump" >&2
            exit 1
        fi
        # バージョンが実際に変わっているか確認
        remote_ver=$(git show origin/HEAD:.claude-plugin/plugin.json 2>/dev/null | jq -r '.version' 2>/dev/null || true)
        if [ -n "$remote_ver" ] && [ "$remote_ver" = "$plugin_ver" ]; then
            echo "ERROR: plugin.json/marketplace.json は diff に含まれていますがバージョンが同じ ($plugin_ver) です。" >&2
            echo "バージョンbump不要なら: just push-without-bump" >&2
            exit 1
        fi
    fi
    # バリデーション
    claude plugin validate .
    jj git push

# push（バージョンbumpなし）
push-without-bump:
    jj git push
