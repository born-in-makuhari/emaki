# emaki
FROM ruby

EXPOSE 80
WORKDIR /srv/emaki/
COPY Gemfile ./Gemfile
COPY Gemfile.lock ./Gemfile.lock

RUN apt-get update && apt-get install -y \
      aptitude \
      ghostscript \
      libpq-dev \
      libqt5webkit5-dev \
      libxml2-dev \
      libxslt1-dev \
      nodejs \
      postgresql-9.4 \
      postgresql-server-dev-9.4 \
      qt5-default \
      redis-server \
      xvfb \
 && aptitude install -y \
      imagemagick \
      libmagick++-dev \
 && rm -rf /var/lib/apt/lists/* \
 && echo "db:5432:*:emaki:emakipostgres" > ~/.pgpass \
 && chmod 600 ~/.pgpass
 && bundle install
 && compass create . -r bootstrap-sass --using bootstrap \
 && compass compile --force

ENV PATH /usr/lib/postgresql/9.4/bin/:$PATH

CMD bash
