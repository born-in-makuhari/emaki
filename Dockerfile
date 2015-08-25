# emaki
FROM ruby:2.0.0

EXPOSE 4567
EXPOSE 80

ADD build /tmp/build/
RUN bash /tmp/build/build.sh

WORKDIR /srv/emaki

CMD redis-server /srv/redis/redis.conf && ruby emaki.rb -p 80 -e production
