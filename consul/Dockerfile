ARG CONSUL_VERSION=latest

FROM hashicorp/consul:${CONSUL_VERSION}
ADD rootfs /
ENTRYPOINT [ "/init", "docker-entrypoint.sh" ]
CMD ["agent", "-dev", "-client", "0.0.0.0"]
