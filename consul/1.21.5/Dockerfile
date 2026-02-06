FROM ghcr.io/socheatsok78-lab/consul:1.21.5

# https://github.com/socheatsok78/dockerfiles
COPY --from=go-discover-dockerswarm / /
COPY --from=go-discover / /
COPY --from=go-netaddrs / /
