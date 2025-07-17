FROM swarmlibs/go-sockaddr:main AS go-sockaddr
FROM swarmlibs/go-netaddrs:main AS go-netaddrs
FROM swarmlibs/go-discover:main AS go-discover

FROM alpine:latest

COPY --from=go-sockaddr /sockaddr /usr/bin/sockaddr
COPY --from=go-netaddrs /netaddrs /usr/bin/netaddrs
COPY --from=go-discover /discover /usr/bin/discover

ADD rootfs /
CMD [ "/consul-init.sh" ]
