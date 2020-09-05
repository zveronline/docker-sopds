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
    SOPDS_SU_NAME="admin" \
    SOPDS_SU_EMAIL="admin@localhost" \
    SOPDS_SU_PASS="admin" \
    CONV_LOG=/sopds/opds_catalog/log \
    MIGRATE=False \
    VERSION=0.47

ADD requirements.txt /requirements.txt
ADD https://github.com/mitshel/sopds/archive/master.zip /sopds.zip
#add fb2c converter for epub and mobi - https://github.com/rupor-github/fb2converter
ADD https://github.com/rupor-github/fb2converter/releases/latest/download/fb2c-linux32.7z /fb2c-linux32.7z
#
RUN apk add --no-cache -U tzdata unzip build-base libxml2-dev libxslt-dev postgresql-dev libffi-dev libc-dev jpeg-dev zlib-dev p7zip \
&& cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime \
&& echo "Europe/Moscow" > /etc/timezone \
&& unzip sopds.zip \
&& rm sopds.zip \
&& mv sopds-* sopds \
&& mv /requirements.txt /sopds/requirements.txt \
&& cd /sopds \
&& pip3 install --upgrade pip setuptools psycopg2-binary \
&& pip3 install --upgrade -r requirements.txt \
&& 7z e -o/sopds/convert/fb2c/ /fb2c-linux32.7z \
&& rm /fb2c-linux32.7z \
&& pip install toml-cli \
&& /sopds/convert/fb2c/fb2c export /sopds/convert/fb2c/ \
&& toml set --toml-path /sopds/convert/fb2c/configuration.toml logger.file.level none \
&& apk del tzdata unzip build-base libxml2-dev libxslt-dev postgresql-dev libffi-dev libc-dev jpeg-dev zlib-dev p7zip \
&& apk add --no-cache -U bash libxml2 libxslt libffi libjpeg zlib postgresql \
&& rm -rf /root/.cache/ \
&& cd /
WORKDIR /sopds
ADD configs/settings.py /sopds/sopds/settings.py
#add fb2c converter for epub and mobi - https://github.com/rupor-github/fb2converter
ADD scripts/fb2conv /sopds/convert/fb2c/fb2conv
RUN chmod +x /sopds/convert/fb2c/fb2conv \
&& ln -sT /sopds/convert/fb2c/fb2conv /sopds/convert/fb2c/fb2epub \
&& ln -sT /sopds/convert/fb2c/fb2conv /sopds/convert/fb2c/fb2mobi
#
#add autocreation of the superuser
RUN apk add --no-cache -U expect
ADD scripts/superuser.exp /sopds/superuser.exp
#
ADD scripts/start.sh /start.sh
RUN chmod +x /start.sh

VOLUME /var/lib/pgsql
EXPOSE 8001

ENTRYPOINT ["/start.sh"]
