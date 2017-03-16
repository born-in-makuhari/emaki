<div align="center">
  <img src="https://github.com/born-in-makuhari/emaki/raw/master/public/images/emaki-logo.png" width="240">
</div>

Emaki
---
dockerでの利用に特化した、シンプルなスライド共有アプリ

## How to use

[docker-compose](https://docs.docker.com/compose/)が最も簡単です。  
以下のコマンドを順に実行してください。

    $ git clone https://github.com/born-in-makuhari/emaki.git
    $ cd emaki
    $ docker-compose up -d
    $ docker-compose exec -T emaki bash -c "bin/start.sh"

ブラウザからアクセスしてください。

    http:// (Docker's host) :12321/

## Tips

- 起動確認

    $ docker-compose top

    emaki
    UID     PID    PPID    C   STIME    TTY      TIME                    CMD
    ----------------------------------------------------------------------------------------
    root   11159   11148   0   22:55   pts/2   00:00:00   /bin/sh -c bash
    root   11201   11159   0   22:55   pts/2   00:00:00   bash
    root   11280   1       0   22:56   ?       00:00:00   ruby emaki.rb -p 80 -e production

    emaki_pg
    UID    PID    PPID    C   STIME   TTY     TIME                      CMD
    ----------------------------------------------------------------------------------------
    999   11027   11013   0   22:55   ?     00:00:00   postgres
    999   11227   11027   0   22:56   ?     00:00:00   postgres: checkpointer process
    999   11228   11027   0   22:56   ?     00:00:00   postgres: writer process
    999   11229   11027   0   22:56   ?     00:00:00   postgres: wal writer process
    999   11230   11027   0   22:56   ?     00:00:00   postgres: autovacuum launcher process
    999   11231   11027   0   22:56   ?     00:00:00   postgres: stats collector process

- 開発環境として使う場合

    $ docker-compose up -d
    $ docker-compose exec -T emaki bash -c "bin/start.sh development"

- テストの実行

    $ docker-compose exec -T emaki rspec

## Emaki ?

[絵巻物 - Wikipedia](https://ja.wikipedia.org/wiki/%E7%B5%B5%E5%B7%BB%E7%89%A9)
