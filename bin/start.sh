# create databases
psql -h db -U emaki -c "create database emaki encoding 'UTF8'"
psql -h db -U emaki -c "create database emaki_test encoding 'UTF8'"

# start server
echo "env: $EMAKI_ENV"
ruby emaki.rb -p 80 -e $EMAKI_ENV > out.log 2>&1 &
