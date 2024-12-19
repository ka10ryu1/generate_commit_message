#!/usr/bin/env bash
# 引数で取得するプルリクエストの数を指定（デフォルトは3）
pr_count=${1:-3}
# 最新のプルリクエスト番号を取得（指定された数だけ）
pr_numbers=$(git log --oneline --grep="Merge pull request #" --reverse | sed -n 's/.*#\([0-9]*\).*/\1/p' | tail -n $pr_count)
# 各プルリクエストのコミットを取得
for pr in $pr_numbers; do
    echo "プルリクエスト #$pr のコミット一覧:"
    # プルリクエストのマージコミットを取得
    merge_commit=$(git log --oneline --grep="Merge pull request #$pr" -n 1 --reverse | awk '{print $1}')
    # マージコミット直前までのコミットを表示し、"##" より前の部分だけを表示
    git log --oneline $merge_commit^..$merge_commit | sed 's/##.*//'
    echo ""
done
