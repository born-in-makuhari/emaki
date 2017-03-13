# 引数がrandomならランダムにポート割り当て
PORT_OPTION=" -p 12321:80 "

if [ $1 -a $1 = "random" ]; then
  PORT_OPTION=" -P "
fi

echo http_proxy:${http_proxy}
echo https_proxy:${https_proxy}

docker run -dti $PORT_OPTION --name emaki \
  --link emaki_pg:db \
  -e http_proxy=${http_proxy}\
  -e https_proxy=${https_proxy}\
  -e PGHOST=db \
  -e PGPORT=5432 \
  -e PGUSER=emaki \
  -v $PWD:/srv/emaki emaki \
  bash

docker exec emaki /bin/bash -c /srv/emaki/dock/compile.sh
docker exec emaki /bin/bash -c /srv/emaki/dock/start.sh
echo
echo "---- ports ----"
docker port emaki
echo "---------------"
echo
