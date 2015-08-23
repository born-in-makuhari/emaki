# emaki
FROM ruby:2.2.0

EXPOSE 4567 

WORKDIR /srv

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -y && apt-get install -y build-essential

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for capybara-webkit
RUN apt-get install -y libqt4-webkit libqt4-dev xvfb

# for a JS runtime
RUN apt-get install -y nodejs

# git
RUN apt-get install -y git
RUN git clone https://github.com/born-in-makuhari/emaki.git

# for Rmagick
RUN apt-get install -y aptitude
RUN aptitude install -y imagemagick libmagick++-dev

# for redis
RUN apt-get -y install redis-server

WORKDIR emaki

ENV \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle

RUN bundle install

RUN bundle install -q --without test
RUN mkdir logs
RUN touch logs/development.log
RUN nohup redis-server & # TODO: 本当は別サーバがいい
RUN nohup ruby emaki/emaki.rb &
