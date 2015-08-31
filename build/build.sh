#!/bin/bash
echo "[emaki] build start"
echo "[emaki] branch: " $1

# Dockerfileがどうやってもうまくいかないので、
# 以下の内容をスクリプト化し、bashで流す。
cd /srv

#
# install packages
#

# updateかなり時間かかる
apt-get update 
apt-get install -y build-essential

# for nokogiri
# apt-get install -y libxml2-dev libxslt1-dev

# for capybara-webkit
# 106パッケージ。とても時間かかる。
# テストしないならいらないのでは？
# apt-get install -y libqt4-webkit libqt4-dev xvfb

# for a JS runtime
# 結構早い
apt-get install -y nodejs

# for Rmagick
# 結構早い
apt-get install -y aptitude
# それなり
aptitude install -y imagemagick libmagick++-dev

# for redis
apt-get install -y redis-server

apt-get install -y ghostscript

#
# clone & install gems
#

# すごく遅い・・・
git clone https://github.com/born-in-makuhari/emaki.git emaki
cd emaki
# TODO: あるブランチに切り替えている。本当はやりたくない
git fetch origin
git checkout -b $1 origin/$1

# qt並に時間かかるので覚悟する
# localeを追加
locale-gen en_EN.UTF-8
# localeを設定
/usr/sbin/update-locale LANG=en_EN.UTF-8

bundle install --without test
compass create . -r bootstrap-sass --using bootstrap
compass compile
mkdir logs
touch logs/development.log
touch logs/production.log

#
# テスト
#

# TODO: 以下のメッセージが出て失敗する
# ruby: symbol lookup error: /usr/local/bundle/extensions/x86_64-linux/2.2.0-static/hiredis-0.4.5/hiredis/ext/hiredis_ext.so: undefined symbol: rb_thread_select
#
# bundle exec rspec

mkdir /srv/redis/
cp /etc/redis/redis.conf /srv/redis/
sed -i -e "s/^daemonize no/daemonize yes/" /srv/redis/redis.conf

echo "[emaki] build end"