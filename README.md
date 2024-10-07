# generate_commit_message
ChatGPT（Web）を使ってコミットメッセージを自動生成する


## インストール

### WSLで使用する場合

1. `sudo apt install xsel xdg-utils` で必要なパッケージをインストールする
1. 設定ファイルを作成する
  - `mkdir -p ~/.local/share/applications`
  - ```
    cat << EOS > ~/.local/share/applications/file-protocol-handler.desktop
    [Desktop Entry]
    Type=Application
    Version=1.0
    Name=File Protocol Handler
    NoDisplay=true
    Exec=rundll32.exe url.dll,FileProtocolHandler
    EOS
    ```
  - `xdg-settings set default-web-browser file-protocol-handler.desktop`