#!/bin/bash

# このスクリプトは、現在のブランチと指定したベースブランチの差分ログを取得し、
# クリップボードへコピーした上で ChatGPT (GPTs) のページを開いて
# プルリクエスト(PR) の説明文を生成する補助を行います。
#
# 使い方:
#   pr_with_gpts.sh <base-branch> [<current-branch>] [<model-name>]
#
#   <base-branch>       : PR のベースとなるブランチ名 (例: develop, main 等)
#   <current-branch>    : PR へマージしたいブランチ名。省略時はカレントブランチを自動取得
#   <model-name>        : ChatGPT のモデル名。省略時は gpt-4o
#
#   例)
#     # カレントブランチ (feature_x) を develop と比較
#     ./pr_with_gpts.sh develop
#
#     # 明示的にブランチを指定
#     ./pr_with_gpts.sh develop feature_x
#
#   生成されたログはクリップボードにコピーされ、ブラウザで GPTs のページが開きます。
#   必要に応じてその場で PR 用の説明文を生成してください。

###############################################################################
# 共通関数
###############################################################################

copy_clipboard() {
    local file_path="$1"
    local sz=$(wc -c < "$file_path") || return 1

    # 64 KiB 超は clip.exe に丸投げ (Windows 向け)
    if (( sz > 64000 )) && command -v clip.exe &>/dev/null; then
        # 文字コード変換 (UTF-8→CP932) を試み、失敗したらそのまま UTF-8 でコピー
        iconv -f utf-8 -t cp932//ignore < "$file_path" 2>/dev/null | clip.exe || cat "$file_path" | clip.exe
        return $?
    fi

    # Windows 直通を優先
    if command -v clip.exe &>/dev/null; then
        # 可能なら CP932 へ変換 (無効文字は削除)、失敗時は UTF-8 のままコピー
        iconv -f utf-8 -t cp932//ignore < "$file_path" 2>/dev/null | clip.exe || cat "$file_path" | clip.exe
        return $?
    fi

    # Wayland
    if command -v wl-copy &>/dev/null; then
        wl-copy -o < "$file_path"
        return $?
    fi

    # X11
    if command -v xsel &>/dev/null; then
        xsel --clipboard --input < "$file_path" &
        return $?
    fi

    echo "Error: クリップボード操作コマンドが見つかりません。" >&2
    return 1
}

###############################################################################
# 前提チェック
###############################################################################

# 必要コマンドの存在確認
for cmd in git xdg-open; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd がインストールされていません。" >&2
        if [[ "$cmd" == "xdg-open" ]]; then
            echo "Ubuntu/Debian: sudo apt install xdg-utils wslu" >&2
        else
            echo "Ubuntu/Debian: sudo apt install $cmd" >&2
        fi
        exit 1
    fi
done

###############################################################################
# 引数処理
###############################################################################

if [[ -z "$1" ]]; then
    echo "Usage: $0 <base-branch> [<current-branch>] [<model-name>]" >&2
    exit 2
fi

BASE_BRANCH="$1"
CURRENT_BRANCH="${2:-$(git rev-parse --abbrev-ref HEAD)}"
DEFAULT_MODEL="gpt-4o"
MODEL="${3:-$DEFAULT_MODEL}"

###############################################################################
# Git 操作
###############################################################################

# 指定ベースブランチを最新にしておく
if git rev-parse --verify "origin/$BASE_BRANCH" &>/dev/null; then
    echo "Fetching origin/$BASE_BRANCH ..."
    git fetch origin "$BASE_BRANCH" --quiet
else
    echo "Warning: origin/$BASE_BRANCH が見つかりません。fetch を試みます..." >&2
    git fetch origin "$BASE_BRANCH" --quiet || {
        echo "Error: origin/$BASE_BRANCH を取得できませんでした。" >&2
        exit 3
    }
fi

# ログを一時ファイルに保存
TXT=".gen_pr_desc_buf.txt"
git log --oneline "origin/${BASE_BRANCH}..${CURRENT_BRANCH}" > "$TXT"

if [[ ! -s "$TXT" ]]; then
    echo "Error: 差分が存在しない、またはログが空です。" >&2
    rm -f "$TXT"
    exit 4
fi

echo "Git log を $TXT に保存しました。行数: $(wc -l < "$TXT")"

###############################################################################
# クリップボードへコピー
###############################################################################

if ! copy_clipboard "$TXT"; then
    echo "Error: クリップボードへのコピーに失敗しました。" >&2
    rm -f "$TXT"
    exit 5
fi

echo "PR 説明文用の git log をクリップボードにコピーしました。"

###############################################################################
# ブラウザで GPTs を開く
###############################################################################

# ※必要に応じてお好みの GPTs URL に変更してください
GPTS_URL="https://chatgpt.com/g/g-6892c30e2c3c8191a30ce2fdb316ddfd-hururikumetusesizuo-cheng-ai?model=${MODEL}"

echo "ChatGPT を開きます: ${GPTS_URL}"
xdg-open "$GPTS_URL" &>/dev/null &

###############################################################################
# 後片付け
###############################################################################

rm -f "$TXT"

exit 0
