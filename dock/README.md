dockerでの起動手順
---

環境に応じて sudo をつけてください。  
明示しない場合、カレントディレクトリはemaki/です。  

以下がめんどくさい場合はクイックスタートがあります。  
初回のdocker build には時間がかかります。

```
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

2. docker run

    コンテナ「emaki」を起動します。

    ```
    docker run -dtP --name emaki -v $PWD:/srv/emaki emaki bash
    ```

3. 必要ファイルのコンパイル

    ```
    docker exec emaki /bin/bash source /srv/emaki/dock/compile.sh
    ```

4. サーバの起動

    ```
    docker exec emaki /bin/bash source /srv/emaki/dock/start.sh

5. 再起動の方法

    コンテナを削除します。

    ```
    . dock/remove.sh
    ```

    または

    ```
    docker stop emaki && docker rm emaki
    ```

    その後、起動手順を行ってください。
