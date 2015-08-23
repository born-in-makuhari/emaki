# emaki
#
# Dockerfileがどうやってもうまくいかないので、
# 以下の内容をスクリプト化し、
# bashで流すように変更する。
#
FROM ruby:2.2.0

EXPOSE 4567
EXPOSE 80

ADD build /tmp/build/
RUN bash /tmp/build/build.sh

CMD ["ruby", "/srv/emaki/emaki.rb"]
