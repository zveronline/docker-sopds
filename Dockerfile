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
    MIGRATE=False \
    CONV_LOG=/sopds/opds_catalog/log \
    VERSION=0.47

ADD https://github.com/mitshel/sopds/archive/master.zip /sopds.zip
ADD requirements.txt /requirements.txt
ADD configs/settings.py /settings.py /sopds/sopds/settings.py
ADD scripts/start.sh /start.sh
#add fb2converter for epub and mobi - https://github.com/rupor-github/fb2converter
ADD https://github.com/rupor-github/fb2converter/releases/latest/download/fb2c-linux32.7z /fb2c-linux32.7z
ADD scripts/fb2conv /fb2conv
#
#add autocreation of the superuser
ADD scripts/superuser.exp /superuser.exp 
#
#incorporate all apk installation, compilation and execution of command in one branch
RUN apk add --no-cache -U tzdata unzip build-base libxml2-dev libxslt-dev postgresql-dev libffi-dev libc-dev jpeg-dev zlib-dev p7zip \
&& cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime \
&& echo "Europe/Moscow" > /etc/timezone \
&& unzip sopds.zip \
&& rm sopds.zip \
&& mv sopds-* sopds \
&& mv /requirements.txt /sopds/requirements.txt \
&& mv /settings.py /sopds/sopds/settings.py \
&& cd /sopds \
&& pip3 install --upgrade pip setuptools psycopg2-binary \
&& pip3 install --upgrade -r requirements.txt \
&& 7z e -o/sopds/convert/fb2c/ /fb2c-linux32.7z \
&& rm /fb2c-linux32.7z \
&& pip install toml-cli \
&& /sopds/convert/fb2c/fb2c export /sopds/convert/fb2c/ \
&& toml set --toml-path /sopds/convert/fb2c/configuration.toml logger.file.level none \
&& mv /fb2conv /sopds/convert/fb2c/fb2conv \
&& chmod +x /sopds/convert/fb2c/fb2conv \
&& ln -sT /sopds/convert/fb2c/fb2conv /sopds/convert/fb2c/fb2epub \
&& ln -sT /sopds/convert/fb2c/fb2conv /sopds/convert/fb2c/fb2mobi \
&& mv /superuser.exp /sopds/superuser.exp \
&& apk del tzdata unzip build-base libxml2-dev libxslt-dev postgresql-dev libffi-dev libc-dev jpeg-dev zlib-dev p7zip \
&& rm -rf /root/.cache/ \
&& apk add --no-cache -U bash libxml2 libxslt libffi libjpeg zlib postgresql expect \
&& chmod +x /start.sh \
&& cd /
#
WORKDIR /sopds

VOLUME /var/lib/pgsql
EXPOSE 8001

ENTRYPOINT ["/start.sh"]
