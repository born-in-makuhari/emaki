mkdir -p db
docker run --name emaki_pg \
  -d \
  -p 5432:5432 \
  -v $PWD/db:/var/lib/postgresql \
  -e POSTGRES_USER=emaki \
  -e POSTGRES_PASSWORD=emakipostgres \
  postgres
