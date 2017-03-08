# emaki
FROM ruby

EXPOSE 4567
EXPOSE 80

# ------------------------------------------------------------
# 動作に必要なパッケージのインストール
#
RUN apt-get update && apt-get install -y \
    aptitude

RUN aptitude install -y \
             imagemagick \
             libmagick++-dev

RUN apt-get install -y \
            nodejs \
            ghostscript \
            redis-server

# ------------------------------------------------------------
# 開発に必要なパッケージのインストール
#
RUN apt-get install -y \
            libxml2-dev \
            libxslt1-dev \
            libqt4-webkit \
            libqt4-dev \
            xvfb
# ------------------------------------------------------------
# redis設定
# redis-server /srv/redis/redis.conf でデーモン起動
#
WORKDIR /srv/redis/
RUN cp /etc/redis/redis.conf .
RUN sed -i -e "s/^daemonize no/daemonize yes/" /srv/redis/redis.conf

# ------------------------------------------------------------
# emakiの依存するgemのインストール
#
WORKDIR /srv/for_bundle/
RUN git clone https://github.com/born-in-makuhari/emaki.git
WORKDIR /srv/for_bundle/emaki/
RUN bundle install

# ------------------------------------------------------------
# 後処理
# docker exec コマンドを正常に動作させるため、
# デフォルトのカレントディレクトリを/srv/emaki直下とする。
#
WORKDIR /srv/emaki/
