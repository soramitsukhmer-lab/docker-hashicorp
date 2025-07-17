FROM hashicorp/consul:latest
ADD --chmod=0755 entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh", "docker-entrypoint.sh" ]
CMD ["agent", "-dev", "-client", "0.0.0.0"]
