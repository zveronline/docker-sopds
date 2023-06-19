# Это форкнутый проект как бы для себя. Так что качайте лучше с основной репы

https://github.com/mitshel/sopds.git


# Introduction

Dockerfile to build a Simple OPDS server docker image.
http://www.sopds.ru

# Installation

Pull the latest version of the image from the docker.

```
docker pull iahtoh/sopds
```

Alternately you can build the image yourself.

```
docker build -t iahtoh/sopds https://github.com/iAHTOH/docker-sopds.git
```

# Quick Start

Run the image

```
docker run --name sopds -d \
   --volume /path/to/library:/library:ro \

   --publish 8081:8001 \
   iahtoh/sopds

```

This will start the sopds server and you should now be able to browse the content on port 8081.

```
docker run --name sopds -d \
   --volume /path/to/library:/library:ro \
   --volume /path/to/database:/var/lib/pgsql \

   --publish 8081:8001 \
   iahtoh/sopds

```

Also you can store postgresql database on external storage.

```
docker run --name sopds -d \
   --volume /path/to/library:/library:ro \
   --env 'DB_USER=sopds' \
   --env 'DB_NAME=sopds' \
   --env 'DB_PASS=sopds' \
   --env 'DB_HOST=""' \
   --env 'DB_PORT=""' \
   --env 'EXT_DB=True' \

   --publish 8081:8001 \
   iahtoh/sopds

```
Also compose yml.


```
 sopds:
            image: iahtoh/sopds:latest
            container_name: sopds
            environment:
                - EXT_DB=True
                - DB_HOST=IP_DB_HOST
                - DB_PORT=5432
                - DB_NAME=sopds
                - DB_USER=sopds
                - DB_PASS=Password
                - SOPDS_SU_EMAIL=k.ahtoh@gmail.com
                - SOPDS_SU_NAME=Admin_User
                - SOPDS_SU_PASS=Password
                - SOPDS_ROOT_LIB=/library
                - SOPDS_INPX_ENABLE=True
                - SOPDS_LANGUAGE=ru-RU
                # Влючение Тлеграмм Бота
                - SOPDS_TMBOT_ENABLE=False
                - CONV_LOG=/sopds/opds_catalog/log
            volumes:
                - /you path to library/e-Book:/library  
                - /docker/sopds/log:/sopds/opds_catalog/log
            ports:
                - 8199:8001
            restart: always   
            depends_on:
                - pgadmin
```             


# Create superuser

By default the superuser will be created with predefined name "admin" and password "admin". But you can manage it via appropriate environmental variables:
```bash
docker run --name sopds -d \
   --volume /path/to/library:/library:ro \
   --volume /path/to/database:/var/lib/pgsql \
   --env 'SOPDS_SU_NAME="your_name_for_superuser"' \
   --env 'SOPDS_SU_EMAIL='"your_mail_for_superuser@your_domain"' \
   --env 'SOPDS_SU_PASS="your_password_for_superuser"' \

   --publish 8081:8001 \
   iahtoh/sopds


# Scan library

```bash
docker exec -ti sopds bash
python3 manage.py sopds_util setconf SOPDS_SCAN_START_DIRECTLY True
```

# Autostart of the SOPDS Telegram-bot

By default the Telegram-bot isn't enabled. But you can configure it to be started with container start at any time. 
```bash
docker run --name sopds -d \
   --volume /path/to/library:/library:ro \
   --volume /path/to/database:/var/lib/pgsql \
   --env 'SOPDS_TMBOT_ENABLE="True"' \

```
Please don't forget to configure the bot itself via interface of SOPDS.
