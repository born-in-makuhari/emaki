docker run -dti -P --name emaki \
  --link emaki_pg:db \
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
