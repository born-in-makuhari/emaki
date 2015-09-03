redis-server /srv/redis/redis.conf
ruby /srv/emaki/emaki.rb -p 80 -e production > out.log 2>&1 &
