# 引数がrandomならランダムにポート割り当て
if [ $1 -a $1 = "random" ]; then
  docker run -dti -P --name emaki -v $PWD:/srv/emaki emaki bash
else
  docker run -dti -p 12321:80 --name emaki -v $PWD:/srv/emaki emaki bash
fi

docker exec emaki /bin/bash -c /srv/emaki/dock/compile.sh
docker exec emaki /bin/bash -c /srv/emaki/dock/start.sh
echo
echo "---- ports ----"
docker port emaki
echo "---------------"
echo
