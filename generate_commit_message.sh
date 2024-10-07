#!/bin/bash

# 一時ファイル
TXT=.gen_commit_mgs_buf.txt
# 1行目にプロンプトを生成し、以降にGitでステージされた箇所を一時ファイルに書き込む
echo -e "コミットメッセージを作成してください。正確で情報量の多い件名で、変更の要点を日本語で50文字以内に簡潔にまとめてください。変更の本質、その理由、変更から生じる重大な影響や考慮事項についての注意点も追記してください。書式はmarkdown形式で適切に改行と箇条書きを実施し、件名を先頭にし、変更点と注意点を段落分けて記載してください。\n\n\"\"\" " > ${TXT}
git diff -w -U0 --ignore-blank-lines --minimal --no-prefix --cached >> ${TXT}
echo "\"\"\"" >> ${TXT}
# クリップボードにコピーする
# WSL2での利用を想定しており、`sudo apt install xsel`が必要
cat ${TXT} | xsel --clipboard --input
# 一時ファイルを削除
rm -rf ${TXT}
# ChatGPTのWebページにアクセスする
xdg-open https://chatgpt.com/
# Microsoft Copilotを利用する（余計な文章が多いのと、遅いので非推奨）
#python3 -m webbrowser "https://www.bing.com/search?q=Bing+AI&showconv=1&FORM=hpcodx"
