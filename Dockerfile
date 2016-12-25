FROM fedora:25
MAINTAINER zveronline@zveronline.ru

ENV SOPDS_VERSION=0.38

RUN dnf install wget python3 unzip
RUN wget https://github.com/mitshel/sopds/archive/v0.38.zip
RUN unzip v0.38.zip && rm v0.38.zip

EXPOSE 8001
CMD ["/bin/bash", "/start.sh"]
