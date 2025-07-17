FROM swarmlibs/go-sockaddr:main AS go-sockaddr
FROM swarmlibs/go-netaddrs:main AS go-netaddrs
FROM swarmlibs/go-discover:main AS go-discover

FROM alpine:latest

COPY --link --from=go-sockaddr /sockaddr /usr/bin/sockaddr
COPY --link --from=go-netaddrs /netaddrs /usr/bin/netaddrs
COPY --link --from=go-discover /discover /usr/bin/discover

ADD rootfs /
CMD [ "/consul-auto-discover.sh" ]
