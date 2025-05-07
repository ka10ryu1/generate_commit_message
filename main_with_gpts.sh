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
git diff --cached -U10 --ignore-blank-lines --minimal --no-prefix >"${TXT}"

# クリップボードにコピー
cat "${TXT}" | xsel --clipboard --input
echo "コミットメッセージのプロンプトをクリップボードにコピーしました。"

# 一時ファイルを削除
rm -f "${TXT}"

# ChatGPTのWebページを開く
URL="https://chatgpt.com/g/g-681abf2258a08191825991d6b65fc97a-komitutometusesizuo-cheng-ai"
echo "ChatGPTを開きます: ${URL}"
xdg-open "${URL}"
