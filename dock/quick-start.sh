
echo http_proxy:${http_proxy}
echo https_proxy:${https_proxy}

docker run -dti -P --name emaki -v $PWD:/srv/emaki \
  -e http_proxy=${http_proxy}\
  -e https_proxy=${https_proxy}\
  emaki bash

docker exec emaki /bin/bash -c /srv/emaki/dock/compile.sh
docker exec emaki /bin/bash -c /srv/emaki/dock/start.sh
echo
echo "---- ports ----"
docker port emaki
echo "---------------"
echo
