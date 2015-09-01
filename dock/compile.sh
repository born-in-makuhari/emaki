# create databases
psql -h db -U emaki -c "create database emaki encoding 'UTF8';"
psql -h db -U emaki -c "create database emaki_test encoding 'UTF8';"
# bundle install
bundle install
# compass compile
compass create . -r bootstrap-sass --using bootstrap
compass compile
