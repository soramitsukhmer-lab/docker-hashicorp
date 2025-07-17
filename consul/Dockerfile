ARG CONSUL_VERSION=latest

FROM swarmlibs/go-sockaddr:main AS go-sockaddr
FROM swarmlibs/go-netaddrs:main AS go-netaddrs
FROM swarmlibs/go-discover:main AS go-discover

FROM hashicorp/consul:${CONSUL_VERSION}

COPY --link --from=go-sockaddr /sockaddr /usr/bin/sockaddr
COPY --link --from=go-netaddrs /netaddrs /usr/bin/netaddrs
COPY --link --from=go-discover /discover /usr/bin/discover

ADD rootfs /
ENTRYPOINT [ "/init", "docker-entrypoint.sh" ]
CMD ["agent", "-dev", "-client", "0.0.0.0"]
