# check EMAKI_ENV

# parameter of bin/start.sh override EMAKI_ENV
#   production (default)
#      or
#   development

if [ $1 ]; then
  export EMAKI_ENV=$1
  echo "env overrided"
fi
echo "env: $EMAKI_ENV"

# create databases
psql -h db -U emaki -c "create database emaki encoding 'UTF8'"
psql -h db -U emaki -c "create database emaki_test encoding 'UTF8'"

# start server
ruby emaki.rb -p 80 -e $EMAKI_ENV > out.log 2>&1 &
