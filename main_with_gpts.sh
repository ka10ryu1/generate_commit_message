#!/bin/bash

copy_clipboard() {
    local file_path="$1"
    local sz=$(wc -c <"$file_path") || return 1

    # 64 KiB 超は clip.exe に丸投げ
    if (( sz > 64000 )) && command -v clip.exe &>/dev/null; then
        clip.exe <"$file_path"
        return $?
    fi

    # Windows 直通を優先
    if command -v clip.exe &>/dev/null; then
        clip.exe <"$file_path"
        return $?
    fi

    # Wayland
    if command -v wl-copy &>/dev/null; then
        wl-copy -o <"$file_path"               # ← -o を追加
        return $?
    fi

    # X11
    if command -v xsel &>/dev/null; then
        xsel --clipboard --input <"$file_path" &
        return $?
    fi

    echo "Error: クリップボード操作コマンドが見つかりません。" >&2
    return 1
}

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
if ! copy_clipboard "${TXT}"; then
    echo "Error: クリップボードへのコピーに失敗しました。" >&2
    rm -f "${TXT}"
    exit 6
fi
echo "コミットメッセージのプロンプトをクリップボードにコピーしました。"

# 一時ファイルを削除
rm -f "${TXT}"

# ChatGPTのWebページを開く
URL="https://chatgpt.com/g/g-681abf2258a08191825991d6b65fc97a-komitutometusesizuo-cheng-ai?model=gpt-4o"
echo "ChatGPTを開きます: ${URL}"
xdg-open "${URL}"
