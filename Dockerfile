FROM fedora:25
MAINTAINER zveronline@zveronline.ru

ENV VERSION 0.41

RUN dnf update -y && dnf install -y python3 python3-devel unzip postgresql postgresql-server postgresql-devel gcc redhat-rpm-config
ADD https://github.com/mitshel/sopds/archive/v0.41.zip /sopds.zip
RUN unzip sopds.zip && rm sopds.zip && mv sopds-* sopds
#ADD ./configs/settings.py /sopds/sopds/settings.py
WORKDIR /sopds
RUN pip3 install --upgrade pip && pip3 install psycopg2 && pip3 install -r requirements.txt
RUN python3 manage.py migrate
#RUN python3 manage.py sopds_util clear
RUN python3 manage.py sopds_util setconf SOPDS_ROOT_LIB '/library'
RUN python3 manage.py sopds_util setconf SOPDS_INPX_ENABLE 'True'
RUN python3 manage.py sopds_util setconf SOPDS_LANGUAGE ru-RU
ADD ./scripts/start.sh /start.sh
RUN chmod +x /start.sh

VOLUME /var/lib/postgresql
EXPOSE 8001

ENTRYPOINT ["/start.sh"]
