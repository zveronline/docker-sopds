FROM python:3.10.9-alpine3.16 AS build-stage
LABEL maintainer="mail@zveronline.ru"

WORKDIR /sopds

ADD https://github.com/ichbinkirgiz/sopds/archive/refs/heads/master.zip /sopds.zip
ARG FB2C_I386=https://github.com/rupor-github/fb2converter/releases/latest/download/fb2c-linux-386.zip
ARG FB2C_ARM64=https://github.com/rupor-github/fb2converter/releases/latest/download/fb2c_linux_arm64.zip

RUN apk add --no-cache -U unzip \
    && unzip /sopds.zip && rm /sopds.zip && mv sopds-*/* ./

COPY requirements.txt .
COPY configs/settings.py ./sopds
COPY scripts/fb2conv /fb2conv
COPY scripts/superuser.exp .

RUN apk add --no-cache -U tzdata build-base libxml2-dev libxslt-dev postgresql-dev libffi-dev libc-dev jpeg-dev zlib-dev curl \
    && cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime \
    && echo "Europe/Moscow" > /etc/timezone \
    && pip3 install --upgrade pip setuptools 'psycopg2-binary>=2.8,<2.9' \
    && pip3 install --upgrade -r requirements.txt \
    && if [ $(uname -m) = "aarch64" ]; then \
        curl -L -o /fb2c_linux.zip ${FB2C_ARM64}; \
    else \
        curl -L -o /fb2c_linux.zip ${FB2C_I386}; \
    fi \
    && unzip /fb2c_linux.zip -d /sopds/convert/fb2c/ \
    && rm /fb2c_linux.zip \
    && pip install toml-cli \
    && /sopds/convert/fb2c/fb2c export /sopds/convert/fb2c/ \
    && toml set --toml-path /sopds/convert/fb2c/configuration.toml logger.file.level none \
    && mv /fb2conv /sopds/convert/fb2c/fb2conv \
    && chmod +x /sopds/convert/fb2c/fb2conv \
    && ln -sT /sopds/convert/fb2c/fb2conv /sopds/convert/fb2c/fb2epub \
    && ln -sT /sopds/convert/fb2c/fb2conv /sopds/convert/fb2c/fb2mobi \
    && mkdir -p /sopds/tmp/ \
    && chmod ugo+w /sopds/tmp/

FROM python:3.10.9-alpine3.16 AS production-stage
LABEL maintainer="mail@zveronline.ru"

ENV DB_USER="sopds" \
    DB_NAME="sopds" \
    DB_PASS="sopds" \
    DB_HOST="" \
    DB_PORT="" \
    EXT_DB="False" \
    TIME_ZONE="Europe/Moscow" \
    SOPDS_ROOT_LIB="/library" \
    SOPDS_INPX_ENABLE="True" \
    SOPDS_LANGUAGE="ru-RU" \
    SOPDS_SU_NAME="admin" \
    SOPDS_SU_EMAIL="admin@localhost" \
    SOPDS_SU_PASS="admin" \
    SOPDS_TMBOT_ENABLE="False" \
    MIGRATE="False" \
    CONV_LOG="/sopds/opds_catalog/log" \
    VERSION="0.47-devel"

COPY --from=build-stage /sopds /sopds
COPY --from=build-stage /usr/local/lib/python3.10/site-packages/ /usr/local/lib/python3.10/site-packages/
COPY scripts/start.sh /start.sh

RUN apk add --no-cache -U bash libxml2 libxslt libffi libjpeg zlib postgresql expect \
    && chmod +x /start.sh

WORKDIR /sopds

VOLUME /var/lib/pgsql
EXPOSE 8001

ENTRYPOINT ["/start.sh"]
