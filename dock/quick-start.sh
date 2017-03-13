# 引数1...sinatra起動環境の指定（デフォルトはproduction）
# 引数2...randomならランダムにポート割り当て

if [ $1 ]; then
  ENV_OPTION=$1
else
  ENV_OPTION="production"
fi

if [ $2 -a $2 = "random" ]; then
  PORT_OPTION=" -P "
else
  PORT_OPTION=" -p 12321:80 "
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
docker exec emaki /bin/bash -c "/srv/emaki/dock/start.sh ${ENV_OPTION}"
echo
echo "---- ports ----"
docker port emaki
echo "---------------"
echo
