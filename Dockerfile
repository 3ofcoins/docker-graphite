# -*- conf -*-

FROM ubuntu:14.04
MAINTAINER Maciej Pasternacki <maciej@3ofcoins.net>

RUN groupadd -g 999 --system graphite
RUN useradd -g 999 -u 999 --system --home=/opt/graphite/storage graphite

RUN apt-get update --yes && apt-get --yes install python-dev python-pip libffi-dev libcairo2

ADD src /usr/src
ADD requirements.txt /usr/src/requirements.txt
RUN set -e -x ; \
    pip install -r /usr/src/requirements.txt ; \
    cd /usr/src/whisper ; python2.7 setup.py install ; \
    cd /usr/src/carbon ; python2.7 setup.py install ; \
    cd /usr/src/graphite-web ; python2.7 setup.py install ; python2.7 check-dependencies.py ; \
    pip freeze > /usr/src/requirements-freeze.txt ; \
    cp /opt/graphite/conf/graphite.wsgi.example /opt/graphite/webapp/graphite/wsgi.py

ADD carbon.conf /opt/graphite/conf/
ADD storage-schemas.conf /opt/graphite/conf/
ADD storage-aggregation.conf /opt/graphite/conf/
ADD local_settings.py /opt/graphite/webapp/graphite/

ADD env_remote_user_middleware.py /usr/local/lib/python2.7/dist-packages/
ADD carbon-cache.sh /carbon-cache
ADD graphite-web.sh /graphite-web

RUN rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

VOLUME /opt/graphite/storage
EXPOSE 2003
EXPOSE 2003/udp
EXPOSE 2004
EXPOSE 8080
