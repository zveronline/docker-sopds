FROM fedora:25
MAINTAINER zveronline@zveronline.ru

RUN dnf install -y python3 unzip
ADD https://github.com/mitshel/sopds/archive/master.zip /sopds.zip
RUN unzip sopds.zip && rm sopds.zip && mv sopds-master sopds
ADD ./configs/settings.py /sopds/sopds/settings.py
WORKDIR /sopds
RUN pip3 install --upgrade pip && pip3 install -r requirements.txt
RUN python3 manage.py migrate
RUN python3 manage.py sopds_util clear
ADD ./scripts/start.sh /start.sh
RUN chmod +x /start.sh

VOLUME /library
EXPOSE 8001

ENTRYPOINT ["/start.sh"]
