# generate_commit_message

ChatGPT（Web）を使ってコミットメッセージやPR説明文の下書きを効率的に作成するための補助スクリプト群です。Gitでステージした差分やブランチのログを取得し、クリップボードにコピーした上でChatGPTの該当ページを開くことで、すぐに生成作業を開始できます。

## 特長
- Gitのステージ済み差分やPR向けのログを自動で収集
- WSL／Linux／Wayland／X11／Windows（clip.exe経由）など複数環境のクリップボードに対応
- 使用したいChatGPTモデルを引数で切り替え可能

## 必要環境
- Bash 4以降
- Git
- 既定のブラウザを開くための `xdg-open`（WSLの場合は `wslview` または `explorer.exe` も利用可）
- クリップボード操作コマンドのいずれか
  - `clip.exe`（Windows／WSL）
  - `wl-copy`（Wayland）
  - `xsel`（X11）

上記に加えて、スクリプト内部で `iconv` を使用するため `glibc` 系の環境が想定されています。

## インストール
### 共通手順
1. リポジトリをクローンし、任意のパスへ配置します。
   ```bash
   git clone https://github.com/<your-account>/generate_commit_message.git
   cd generate_commit_message
   ```
2. 実行権限を付与します。
   ```bash
   chmod +x main.sh commit_with_gpts.sh pullrequest_with_gpts.sh get_commit_msg_by_PR.sh
   ```
3. パスを通すか、エイリアスを設定すると便利です。
   ```bash
   echo 'alias gen-commit="/path/to/generate_commit_message/main.sh"' >> ~/.bashrc
   ```

### WSLで使用する場合
1. 必要なパッケージをインストールします。
   ```bash
   sudo apt install xsel xdg-utils wslu
   ```
2. Windows側のブラウザを `file://` で開けるよう設定します。
   ```bash
   mkdir -p ~/.local/share/applications
   cat <<'EOS' > ~/.local/share/applications/file-protocol-handler.desktop
   [Desktop Entry]
   Type=Application
   Version=1.0
   Name=File Protocol Handler
   NoDisplay=true
   Exec=rundll32.exe url.dll,FileProtocolHandler
   EOS
   xdg-settings set default-web-browser file-protocol-handler.desktop
   ```

## 使い方
### コミットメッセージ用プロンプトを生成する（`main.sh`）
1. Gitでコミットしたい変更をステージします。
   ```bash
   git add <file>
   ```
2. スクリプトを実行します。引数にChatGPTのモデル名を渡すと上書きできます（既定は `gpt-4o`）。
   ```bash
   ./main.sh            # 既定のモデルで開く
   ./main.sh gpt-4o-mini
   ```
3. ステージ済み差分とプロンプト文がクリップボードにコピーされ、ChatGPTの画面が開きます。貼り付けて生成したメッセージをコミットに利用してください。

### GPTsに差分のみ渡す（`commit_with_gpts.sh`）
- カスタムGPT（コミットメッセージ用）に差分だけを送って文章生成したい場合に使います。
- 使い方は `main.sh` と同じですが、既定モデルは `gpt-5` で、差分のみをコピーします。
  ```bash
  ./commit_with_gpts.sh
  ./commit_with_gpts.sh gpt-4o
  ```

### PR説明文の下書きを生成する（`pullrequest_with_gpts.sh`）
1. ベースブランチを指定して実行します。第2引数に比較対象ブランチ、第3引数にモデル名を指定できます（既定ブランチは現在のブランチ、モデルは `gpt-5`）。
   ```bash
   ./pullrequest_with_gpts.sh develop
   ./pullrequest_with_gpts.sh main feature/add-api gpt-4o
   ```
2. 指定したベースブランチとの `git log` がクリップボードにコピーされ、PR説明文を生成するためのChatGPTページが開きます。

### マージ済みPRのコミット件名を参照する（`get_commit_msg_by_PR.sh`）
- 過去のマージコミットからPR番号ごとのコミット件名を抽出します。引数に取得したいPR件数を指定できます（既定は3件）。
  ```bash
  ./get_commit_msg_by_PR.sh        # 直近3件
  ./get_commit_msg_by_PR.sh 5      # 直近5件
  ```

## ヒント
- 差分が大きい場合、`clip.exe` の文字数制限を超えることがあります。エラーが出た際は一時的に差分を分割してコミットするか、`git diff --cached > diff.txt` のようにファイルへ保存して手動で対応してください。
- モデル名はURLパラメータとして使用されます。利用可能なモデルはChatGPT側のプランによって異なるため、エラーになる場合は別のモデル名を指定してください。

## ライセンス
このリポジトリは [MIT License](./LICENSE) の下で提供されています。
