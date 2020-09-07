FROM binhex/arch-rtorrentvpn:latest

# install stubby, stubby
RUN pacman -Syu \
    && pacman -S --noconfirm stubby \
    && rm -f /etc/stubby/stubby.yml \
    && mkdir -p /temp

ADD stuff /temp

#Expose port
EXPOSE 53/tcp
EXPOSE 53/udp

# run init script
CMD ["/bin/bash", "/temp/startup.sh"]
