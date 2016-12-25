FROM fedora:25
MAINTAINER zveronline@zveronline.ru

ENV SOPDS_VERSION=0.38

RUN dnf install -y python3 unzip
ADD https://github.com/mitshel/sopds/archive/v0.38.zip /sopds.zip
RUN unzip sopds.zip && rm sopds.zip && mv sopds-0.38 sopds
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
#CMD ["/bin/bash", "/start.sh"]
