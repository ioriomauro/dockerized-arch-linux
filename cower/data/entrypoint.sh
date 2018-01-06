#!/bin/bash
set -ue

ARGS="$@"
su - developer -c "cd /home/developer; /usr/bin/cower ${ARGS}"
