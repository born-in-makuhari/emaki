dockerでの起動手順
---

〜はじめに〜

emaki/ディレクトリから始めてください。  
dockerコマンドにはsudoをつけない環境であること前提です。  
環境に応じて sudo をつけてください。  
明示しない場合、カレントディレクトリはemaki/です。  

1. とにかくビルドして動かしたい！

    以下がめんどくさい場合はクイックスタートがあります。  
    初回のdocker build には時間がかかります。  

    ```
    . dock/build.sh
    . dock/quick-start.sh
    ```

1. docker build

    以下を実行してください。  
    emaki:latest を上書きします。  
    ソースファイルが変わるだけなら、  
    buildし直す必要はありません。  

    ```
    docker build -t emaki .
    ```

1. サーバを起動

    コンテナ「emaki」を起動し、  
    必要ファイルをダウンロード＆コンパイルし、  
    サーバ(とセッションストア)を起動します。

    ```
    docker run -dtP --name emaki -v $PWD:/srv/emaki emaki bash
    docker exec emaki /bin/bash -c /srv/emaki/dock/compile.sh
    docker exec emaki /bin/bash -c /srv/emaki/dock/start.sh
    ```

1. サーバの停止

    コンテナを削除します。  

    ```
    . dock/remove.sh
    ```
