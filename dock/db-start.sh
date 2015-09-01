mkdir -p db
docker run --name emaki_pg \
  -d \
  -v $PWD/db:/var/lib/postgresql \
  postgres
