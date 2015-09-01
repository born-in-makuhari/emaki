dockerでの起動手順
---

〜はじめに〜

dockerコマンドにはsudoをつけない環境であること前提です。  
sudo をつける環境の場合、先に  
`alias docker="sudo docker"`と実行してください。  
明示しない場合、カレントディレクトリはemaki/です。  

---

## emaki を動かす場合

1. とにかくビルドして動かしたい！

    以下を順番に実行してください。  
    初回のdocker build には時間がかかります。  

    ```
    . dock/build.sh
    . dock/db-start.sh
    . dock/quick-start.sh
    ```

1. docker build

    以下を実行してください。  
    emaki:latest を上書きします。  
    ソースファイルが変わるだけなら、  
    buildし直す必要はありません。  

    ```
    . dock/build.sh
    ```

1. DBを起動

    コンテナ「emaki_pg」を起動します。  
    postgreSQLが稼働するコンテナです。  
    データは db/ 配下に保存するため、  
    コンテナの生死はデータの永続化に影響しません。  

    ```
    . dock/db-restart.sh
    ```

1. サーバを起動

    コンテナ「emaki」を起動し、  
    必要ファイルをダウンロード＆コンパイルし、  
    DBコンテナ「emaki_pg」と接続し、  
    サーバ(とセッションストア)を起動します。

    ```
    . dock/quick-start.sh
    ```

1. サーバの停止

    コンテナを削除します。  

    ```
    . dock/remove.sh
    ```

1. DBの停止

    DBコンテナを削除します。  
    データは db/ 配下に残ります。  

    ```
    . dock/db-stop.sh
    . dock/db-restart.sh # stop & start
    ```

---

## emaki を開発する場合

1. ソースコードの編集

    たった今cloneしてきたお手元のソースを弄ってください。  
    コンテナも同じソースを見ています。  

1. テストの実行

    dock/rspecを使ってください。  
    オプションも通常のrspecのように使えます。  

    ```
    . dock/rspec
    . dock/rspec -t type:feature
    ```
