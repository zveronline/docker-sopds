#!/bin/bash
cd /sopds

python3 manage.py sopds_server start & python3 manage.py sopds_scanner start
