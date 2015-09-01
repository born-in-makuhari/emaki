docker run -dti -P --name emaki --link emaki_pg:db -v $PWD:/srv/emaki emaki bash
docker exec emaki /bin/bash -c /srv/emaki/dock/compile.sh
docker exec emaki /bin/bash -c /srv/emaki/dock/start.sh
echo
echo "---- ports ----"
docker port emaki
echo "---------------"
echo
