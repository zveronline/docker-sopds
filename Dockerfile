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
    CONV_LOG=/sopds/opds_catalog/log \
    MIGRATE=False \
    VERSION=0.47

RUN apk add --no-cache -U tzdata bash nano build-base libxml2-dev libxslt-dev unzip postgresql postgresql-dev libffi-dev libc-dev jpeg-dev zlib-dev
RUN cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime
RUN echo "Europe/Moscow" > /etc/timezone
RUN apk del tzdata
ADD https://github.com/mitshel/sopds/archive/master.zip /sopds.zip
RUN unzip sopds.zip && rm sopds.zip && mv sopds-* sopds
ADD configs/settings.py /sopds/sopds/settings.py
ADD requirements.txt /sopds/requirements.txt
WORKDIR /sopds
RUN pip3 install --upgrade pip setuptools psycopg2-binary && pip3 install --upgrade -r requirements.txt
#
#add fb2c converter for epub and mobi - https://github.com/rupor-github/fb2converter
ADD https://github.com/rupor-github/fb2converter/releases/latest/download/fb2c-linux32.7z /fb2c-linux32.7z
RUN apk add --no-cache -U p7zip \
&& 7z e -o/sopds/convert/fb2c/ /fb2c-linux32.7z \
&& rm /fb2c-linux32.7z \
&& apk del p7zip \
&& pip install toml-cli \
&& rm -rf /root/.cache/ \
&& /sopds/convert/fb2c/fb2c export /sopds/convert/fb2c/ \
&& toml set --toml-path /sopds/convert/fb2c/configuration.toml logger.file.level none
ADD scripts/fb2conv /sopds/convert/fb2c/fb2conv
RUN chmod +x /sopds/convert/fb2c/fb2conv \
&& ln -sT /sopds/convert/fb2c/fb2conv /sopds/convert/fb2c/fb2epub \
&& ln -sT /sopds/convert/fb2c/fb2conv /sopds/convert/fb2c/fb2mobi
#
ADD scripts/start.sh /start.sh
RUN chmod +x /start.sh

VOLUME /var/lib/pgsql
EXPOSE 8001

ENTRYPOINT ["/start.sh"]
