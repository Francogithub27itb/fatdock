#!/bin/bash

sleep 3

cp -v /tmp/announcement_config.py /srv/jupyterhub

jupyterhub --config /usr/local/etc/jupyterhub/jupyterhub_config.py --upgrade-db
