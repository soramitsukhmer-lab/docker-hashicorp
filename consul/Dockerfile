FROM hashicorp/consul:latest
ADD --chmod=0755 init /init
ENTRYPOINT [ "/init", "docker-entrypoint.sh" ]
CMD ["agent", "-dev", "-client", "0.0.0.0"]
