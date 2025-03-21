#!/bin/bash

# 一時ファイル名
TXT=".gen_commit_mgs_buf.txt"

# デフォルトモデル名を設定し、引数で上書き可能に
DEFAULT_MODEL="gpt-4o"
MODEL="${1:-$DEFAULT_MODEL}"

# 必要なコマンドのチェック (xsel, git)
if ! command -v xsel &>/dev/null; then
    echo "Error: xselがインストールされていません。"
    echo "Ubuntu/Debian: sudo apt install xsel"
    exit 1
elif ! command -v xdg-open &>/dev/null; then
    echo "Error: xdg-openがインストールされていません。"
    echo "Ubuntu/Debian: sudo apt install xdg-utils wslu"
    exit 2
elif ! command -v git &>/dev/null; then
    echo "Error: gitがインストールされていません。"
    echo "Ubuntu/Debian: sudo apt install git"
    exit 3
fi

# ステージされた変更がない場合のチェック
if [ -z "$(git diff --name-only --cached)" ]; then
    echo "Error: ステージされた変更がありません。変更を追加してください。"
    exit 4
fi

# プロンプトとGit差分を一時ファイルに書き込む
{
    echo -e "コミットメッセージを作成してください。正確で情報量の多い件名で、変更の要点を日本語で50文字以内に簡潔にまとめてください。\n変更の本質、その理由、変更から生じる重大な影響や考慮事項についての注意点も追記してください。\n書式はmarkdown形式で適切に改行と箇条書きを実施し、件名を先頭にし、変更点と注意点を段落分けて記載してください。\n"
    echo -e "以下は記入例です。\n\"\"\"\n計測デコレータを追加して関数の実行時間をログに記録\n## 変更点\n- 関数実行時間を計測するデコレータを追加\n\n## 注意点\n- ログレベルは固定されているため、詳細なログが出力される\"\"\"\n"
    echo -e "以下は実際にコミットメッセージの作成に使用するgitの差分です。\n\"\"\""
    git diff --cached -U10 --ignore-blank-lines --minimal --no-prefix
    echo "\"\"\""
} >"${TXT}"

# クリップボードにコピー
cat "${TXT}" | xsel --clipboard --input
echo "コミットメッセージのプロンプトをクリップボードにコピーしました。"

# 一時ファイルを削除
rm -f "${TXT}"

# ChatGPTのWebページを開く
URL="https://chatgpt.com/?model=${MODEL}"
echo "ChatGPTを開きます: ${URL}"
xdg-open "${URL}"
