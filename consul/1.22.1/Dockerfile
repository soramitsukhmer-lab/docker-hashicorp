FROM ghcr.io/socheatsok78/go-discover-dockerswarm:latest AS go-discover-dockerswarm

FROM ghcr.io/socheatsok78-lab/consul:1.22.1

# https://github.com/socheatsok78/dockerfiles
COPY --from=go-discover-dockerswarm / /
