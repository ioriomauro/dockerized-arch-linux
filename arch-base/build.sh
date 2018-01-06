#!/bin/bash
# § http://kilabit.info/journal/2015/11/Building_Docker_Image_with_Arch_Linux
set -ue

BASE=$(dirname $(readlink -f "$0"))
TMPDIR=$(mktemp -p "$BASE"/data -d)
TMPFILE=$(mktemp -p "$BASE"/data)
PACCFG=$(mktemp -p "$BASE"/data)
IMGNAME="data/arch-strap.$(date -u +"%Y-%m-%dT%H-%M-%S").tar"
LATESTNAME="data/arch-strap.latest.tar"
# Minimum packages: pacman
# Some other packages (e.g.: git) fail to install without:
#   - chsh (from util-linux)
#   - systemd-sysusers (from systemd)
#PKGS="coreutils pacman pacman-mirrorlist sed gzip"
PKGS="pacman util-linux systemd sed gzip"
REALUID=$(id -ru)
REALGID=$(id -rg)

function atexit() {
    if [ "$(findmnt "$TMPDIR")" != "" ]; then
        sudo umount "$TMPDIR"
    fi
    if [ -d "$TMPDIR" ]; then
        sudo rm -rf "$TMPDIR"
    fi
    if [ -f "$TMPFILE" ]; then
        rm "$TMPFILE"
    fi
    if [ -f "$PACCFG" ]; then
        rm "$PACCFG"
    fi
    popd >/dev/null 2>/dev/null
}
trap atexit EXIT

pushd "$BASE" >/dev/null 2>/dev/null

cp /etc/pacman.conf "$PACCFG"
cat <<EOF >>"$PACCFG"
[options]
NoExtract   = usr/share/doc/*
NoExtract   = usr/share/help/*
NoExtract   = usr/share/gtk-doc/*
NoExtract   = usr/share/i18n/* !usr/share/i18n/locales/en_US !usr/share/i18n/locales/en_GB !usr/share/i18n/locales/i18n !usr/share/i18n/locales/iso14651_* !usr/share/i18n/locales/translit_* !usr/share/i18n/charmaps/UTF-8.gz
NoExtract   = usr/share/iana-etc/*
NoExtract   = usr/share/locale/* !usr/share/locale/en_US/* !usr/share/locale/locale.alias
NoExtract   = usr/share/info/*
NoExtract   = usr/share/man/*
NoExtract   = usr/share/zoneinfo/* !usr/share/zoneinfo/UTC
NoExtract   = usr/share/vim/vim74/lang/* usr/share/licenses*
NoExtract   = usr/bin/modprobed_db
NoExtract   = etc/pacman.d/mirrorlist
EOF

# Start here
cat <<EOF | sudo /bin/bash -s
set -ue
mount -t tmpfs tmpfs "$TMPDIR"

# Bootstrap arch-linux
pacstrap -c -C "$PACCFG" -d "$TMPDIR" $PKGS

# Set hostname, zoneinfo and locale
echo "arch-strap" > "$TMPDIR"/etc/hostname
if [ ! -f "$TMPDIR"/etc/localtime ]; then
    cp -f "$TMPDIR"/usr/share/zoneinfo/UTC "$TMPDIR"/etc/localtime
fi
echo "en_US.UTF-8 UTF-8" > "$TMPDIR"/etc/locale.gen
arch-chroot "$TMPDIR" /usr/bin/sh -c "/usr/bin/locale-gen; /usr/bin/pacman -Rs --noconfirm sed gzip"

# Create the tar archive
echo "Creating tar archive. This may take a while..."
tar --numeric-owner --warning=no-file-ignored --xattrs --acls -C "$TMPDIR" -cf "$TMPFILE" .

mv "$TMPFILE" "$IMGNAME"
chown $REALUID:$REALGID "$IMGNAME"

umount "$TMPDIR"

EOF

ln -sf "$IMGNAME" "$LATESTNAME"
