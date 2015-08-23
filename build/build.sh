#!/bin/bash
echo "[emaki] build start"

# Dockerfileがどうやってもうまくいかないので、
# 以下の内容をスクリプト化し、bashで流す。
mkdir /srv
cd /srv

echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list

#
# install packages
#

# updateかなり時間かかる
apt-get update 
apt-get install -y build-essential
apt-get install -y vim

# for nokogiri
apt-get install -y libxml2-dev libxslt1-dev

# for capybara-webkit
# 106パッケージ。とても時間かかる。
# テストしないならいらないのでは？
apt-get install -y libqt4-webkit libqt4-dev xvfb

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

#
# clone & install gems
#

# すごく遅い・・・
git clone https://github.com/born-in-makuhari/emaki.git emaki
cd emaki

# ワーニング出るけど気にしない
# qt並に時間かかるので覚悟する
bundle install --without test
compass create . -r bootstrap-sass --using bootstrap
compass compile
mkdir logs
touch logs/development.log

#
# redis起動
#
nohup redis-server & # TODO: 本当は別サーバがいい

#
# テスト
#

# TODO: 以下のメッセージが出て失敗する
# ruby: symbol lookup error: /usr/local/bundle/extensions/x86_64-linux/2.2.0-static/hiredis-0.4.5/hiredis/ext/hiredis_ext.so: undefined symbol: rb_thread_select
#
# bundle exec rspec

echo "[emaki] build end"
