FROM fedora:25
MAINTAINER zveronline@zveronline.ru

ENV DB_USER=sopds \
    DB_NAME=sopds \
    DB_PASS=sopds \
    DB_HOST="" \
    DB_PORT="" \
    VERSION=0.41

RUN dnf update -y && dnf install -y python3 python3-devel unzip postgresql postgresql-server postgresql-devel gcc redhat-rpm-config
ADD https://github.com/mitshel/sopds/archive/v0.41.zip /sopds.zip
RUN unzip sopds.zip && rm sopds.zip && mv sopds-* sopds
ADD ./configs/settings.py /sopds/sopds/settings.py
WORKDIR /sopds
RUN pip3 install --upgrade pip && pip3 install psycopg2 && pip3 install -r requirements.txt
ADD ./scripts/start.sh /start.sh
RUN chmod +x /start.sh

VOLUME /var/lib/pgsql
EXPOSE 8001

ENTRYPOINT ["/start.sh"]
