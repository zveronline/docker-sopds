FROM python:3-alpine
MAINTAINER zveronline@zveronline.ru

ENV DB_USER=sopds \
    DB_NAME=sopds \
    DB_PASS=sopds \
    DB_HOST="" \
    DB_PORT="" \
    EXT_DB=False \
    SOPDS_ROOT_LIB="/library" \
    SOPDS_INPX_ENABLE=True \
    SOPDS_LANGUAGE=ru-RU \
    MIGRATE=False \
    VERSION=0.47

ADD requirements.txt /requirements.txt
ADD https://github.com/mitshel/sopds/archive/master.zip /sopds.zip
RUN apk add --no-cache -U tzdata unzip build-base libxml2-dev libxslt-dev postgresql-dev libffi-dev libc-dev jpeg-dev zlib-dev \
&& cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime \
&& echo "Europe/Moscow" > /etc/timezone \
&& unzip sopds.zip \
&& rm sopds.zip \
&& mv sopds-* sopds \
&& mv /requirements.txt /sopds/requirements.txt \
&& cd /sopds \
&& pip3 install --upgrade pip setuptools psycopg2-binary \
&& pip3 install --upgrade -r requirements.txt \
&& apk del tzdata unzip build-base libxml2-dev libxslt-dev postgresql-dev libffi-dev libc-dev jpeg-dev zlib-dev \
&& apk add --no-cache -U bash libxml2 libxslt libffi libjpeg zlib postgresql \
&& rm -rf /root/.cache/ \
&& cd /
WORKDIR /sopds
ADD configs/settings.py /sopds/sopds/settings.py
ADD scripts/start.sh /start.sh
RUN chmod +x /start.sh

VOLUME /var/lib/pgsql
EXPOSE 8001

ENTRYPOINT ["/start.sh"]
