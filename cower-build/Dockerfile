FROM ioriomauro/arch-cower:latest

LABEL maintainer="Mauro Iorio <iorio.mauro@gmail.com>"

ADD ./data/entrypoint.sh /
ADD ./data/build-pkgs.sh /home/developer/

VOLUME /packages
    
ENTRYPOINT [ "/entrypoint.sh" ]
