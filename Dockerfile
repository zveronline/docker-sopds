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

RUN apk add --no-cache -U tzdata bash nano build-base libxml2-dev libxslt-dev unzip postgresql postgresql-dev libffi-dev libc-dev jpeg-dev zlib-dev
RUN cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime
RUN echo "Europe/Moscow" > /etc/timezone
RUN apk del tzdata
ADD http://www.sopds.ru/images/archives/sopds-v0.47.zip /sopds.zip
RUN unzip sopds.zip && rm sopds.zip && mv sopds-* sopds
ADD configs/settings.py /sopds/sopds/settings.py
ADD requirements.txt /sopds/requirements.txt
WORKDIR /sopds
RUN pip3 install --upgrade pip setuptools psycopg2-binary && pip3 install --upgrade -r requirements.txt
ADD scripts/start.sh /start.sh
RUN chmod +x /start.sh

VOLUME /var/lib/pgsql
EXPOSE 8001

ENTRYPOINT ["/start.sh"]
