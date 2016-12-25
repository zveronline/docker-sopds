FROM fedora:25
MAINTAINER zveronline@zveronline.ru

ENV SOPDS_VERSION=0.38

RUN wget https://github.com/mitshel/sopds/archive/v0.38.tar.gz
