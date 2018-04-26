FROM fedora:27
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
    VERSION=0.46

RUN dnf update -y && dnf install -y python3 python3-devel unzip postgresql postgresql-server postgresql-devel gcc redhat-rpm-config
ADD http://www.sopds.ru/images/archives/sopds-v0.46.zip /sopds.zip
RUN unzip sopds.zip && rm sopds.zip && mv sopds-* sopds
ADD ./configs/settings.py /sopds/sopds/settings.py
WORKDIR /sopds
RUN pip3 install --upgrade pip && pip3 install psycopg2 && pip3 install -r requirements.txt
ADD ./scripts/start.sh /start.sh
RUN chmod +x /start.sh

VOLUME /var/lib/pgsql
EXPOSE 8001

ENTRYPOINT ["/start.sh"]
