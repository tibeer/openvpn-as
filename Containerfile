FROM ubuntu:22.04

ARG DEBIAN_FRONTEND="noninteractive"

RUN mkdir -p /etc/apt/keyrings \
    && apt update \
    && apt install -y \
        ca-certificates \
        curl \
        gnupg \
        tzdata \
    && ln -fs "/usr/share/zoneinfo/Etc/UTC" /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && curl -fsSL https://as-repository.openvpn.net/as-repo-public.gpg | gpg --dearmor > /etc/apt/keyrings/openvpn-as.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/openvpn-as.gpg] http://as-repository.openvpn.net/as/debian jammy main" > /etc/apt/sources.list.d/openvpn-as.list \
    && apt update \
    && apt install -y openvpn-as \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /dev/net \
    && mknod /dev/net/tun c 10 200 \
    && printf 'DELETE\nyes\nyes\n1\nrsa\n2048\nrsa\n2048\n943\n9443\nyes\nyes\nyes\nyes\nSICHERH3IT\nSICHERH3IT\n\n' | /usr/local/openvpn_as/bin/ovpn-init; echo configured

EXPOSE 943/tcp 1194/udp 443/tcp

ENTRYPOINT /usr/local/openvpn_as/scripts/openvpnas --nodaemon --umask=0077 --pidfile=/openvpn.pid --logfile=/openvpn.log
