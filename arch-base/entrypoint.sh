#!/bin/sh
cd
export USER="$(id -un)"
. /etc/profile
exec "$@"
