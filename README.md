https://github.com/mitshel/sopds.git


# Introduction

Dockerfile to build a Simple OPDS server docker image.
http://www.sopds.ru

# Installation

Pull the latest version of the image from the docker.

```
docker pull zveronline/docker-sopds:latest
```

Alternately you can build the image yourself.

```
docker build -t zveronline/sopds:latest https://git.zveronline.ru/zveronline/docker-sopds.git
```

# Quick Start

Run the image

```
docker run --name sopds -d \
   --volume /path/to/library:/library:ro \
   --publish 8081:8001 \
   zveronline/sopds:latest
```

This will start the sopds server and you should now be able to browse the content on port 8081.


# Scan library

```bash
docker exec -ti sopds bash
python3 manage.py sopds_scanner scan --daemon
```
