https://github.com/mitshel/sopds.git


# Introduction

Dockerfile to build a Simple OPDS server docker image.
http://www.sopds.ru

# Installation

Pull the latest version of the image from the docker.

```
docker pull zveronline/sopds
```

Alternately you can build the image yourself.

```
docker build -t zveronline/sopds https://github.com/zveronline/docker-sopds.git
```

# Quick Start

Run the image

```
docker run --name sopds -d \
   --volume /path/to/library:/library:ro \
   --publish 8081:8001 \
   zveronline/sopds
```

This will start the sopds server and you should now be able to browse the content on port 8081.

```
docker run --name sopds -d \
   --volume /path/to/library:/library:ro \
   --volume /path/to/database:/var/lib/pgsql \
   --publish 8081:8001 \
   zveronline/sopds
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
   zveronline/sopds
```


# Create superuser

By default the superuser will be created with default name "admin" and password "admin". Bu you can change it via appropriate variables:
```bash
docker run --name sopds -d \
   --volume /path/to/library:/library:ro \
   --volume /path/to/database:/var/lib/pgsql \
   --env 'SOPDS_SU_NAME="your_name_for_superuser"' \
   --env 'SOPDS_SU_EMAIL='"your_mail_for_superuser@your_domain"' \
   --env 'SOPDS_SU_PASS="your_password_for_superuser"' \
   --publish 8081:8001 \
   zveronline/sopds
```

# Scan library

```bash
docker exec -ti sopds bash
python3 manage.py sopds_util setconf SOPDS_SCAN_START_DIRECTLY True
```
