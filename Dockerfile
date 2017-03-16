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
            redis-server \
            postgresql-9.4 \
            postgresql-server-dev-9.4 \
            libpq-dev

# postgres へのパスを通す
RUN echo "export PATH=/usr/lib/postgresql/9.4/bin/:$PATH" >> ~/.bash_profile
RUN . ~/.bash_profile
# DB接続時、パスワードを要求されないための設定
RUN echo "db:5432:*:emaki:emakipostgres" > ~/.pgpass
RUN chmod 600 ~/.pgpass

# ------------------------------------------------------------
# 開発に必要なパッケージのインストール
#
RUN apt-get install -y \
            libxml2-dev \
            libxslt1-dev \
            qt5-default \
            libqt5webkit5-dev \
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
WORKDIR /srv/emaki/
ADD Gemfile ./Gemfile
ADD Gemfile.lock ./Gemfile.lock
RUN bundle install

# ------------------------------------------------------------
# css生成
#

# compass compile
RUN compass create . -r bootstrap-sass --using bootstrap
RUN compass compile --force
CMD bash
