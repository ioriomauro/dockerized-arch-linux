#!/bin/bash
set -ue

cd /home/developer
exec /usr/bin/cower "$@"
