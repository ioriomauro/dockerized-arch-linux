Arch Linux image based on pacstrap
==================================

You'll find here all You need to build a fresh Arch Linux docker image based
on arch-install-scripts and pacstrap.

The `build.sh` script uses another Arch Linux image (built from official ISO)
to get the tools needed to generate a brand new image.

The basic step is a simple and lightweight `pacstrap pacman` with just some
other classic tweeks (see [Arch Linux Installation Guide](https://wiki.archlinux.org/index.php/installation_guide "Installation guide - ArchWiki")).

**NOTE:** The `build.sh` script runs a temporary container in `privileged` mode.
      This is necessary to let `pacstrap` and `arch-chroot` do their job,
      mounting pseudo-filesystems as required.

As a side effect You'll find a tar in the `dist` folder containing what has
been generated from `pacstrap`.
