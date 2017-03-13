# 第一引数を-eに設定
echo "env: ${1}"
ruby /srv/emaki/emaki.rb -p 80 -e $1 > out.log 2>&1 &
