#!/bin/bash

export BORG_REPO="borguser@192.168.0.109:~/backups/MainServer"
export BORG_PASSPHRASE="<YOUR KEY>"

borg create --verbose --stats \
    ::'{hostname}-{now:%Y-%m-%d_%H:%M}' \
    /data

borg prune --verbose --list \
    --keep-daily=7 \
    --keep-weekly=4 \
    --keep-monthly=6

borg compact
