FROM alpine:latest
LABEL maintainer "Steven Iveson <steve@iveson.eu>"
LABEL source "https://github.com/sjiveson/nfs-server-alpine"
LABEL branch "master"
ENV WEBPROC_VERSION 0.4.0
ENV WEBPROC_URL https://github.com/jpillora/webproc/releases/download/v0.4.0/webproc_0.4.0_linux_armv7.gz

COPY Dockerfile README.md /

RUN apk add --no-cache --update --verbose nfs-utils bash iproute2 curl && \
    curl -sL $WEBPROC_URL | gzip -d - > /usr/local/bin/webproc && \
    chmod +x /usr/local/bin/webproc && \
    rm -rf /var/cache/apk /tmp /sbin/halt /sbin/poweroff /sbin/reboot && \
    mkdir -p /var/lib/nfs/rpc_pipefs /var/lib/nfs/v4recovery && \
    echo "rpc_pipefs    /var/lib/nfs/rpc_pipefs rpc_pipefs      defaults        0       0" >> /etc/fstab && \
    echo "nfsd  /proc/fs/nfsd   nfsd    defaults        0       0" >> /etc/fstab

COPY exports /etc/
COPY nfsd.sh /usr/bin/nfsd.sh
COPY .bashrc /root/.bashrc

RUN chmod +x /usr/bin/nfsd.sh

ENTRYPOINT ["webproc","-c","/etc/exports","--","/usr/bin/nfsd.sh"]
