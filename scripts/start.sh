#!/bin/bash
python3 manage.py sopds_scanner start --daemon
python3 manage.py sopds_server start --daemon
