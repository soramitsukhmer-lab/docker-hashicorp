FROM ghcr.io/socheatsok78-lab/vault:1.20.0

# https://github.com/socheatsok78/dockerfiles
COPY --from=go-discover-dockerswarm / /

# https://github.com/soramitsukhmer-lab/vault-plugin-catalog
ARG TARGETARCH
ARG VAULT_PLUGIN_CATALOG_VERSION=0.1.0-rc.11
ADD --chmod=0755 https://github.com/soramitsukhmer-lab/vault-plugin-catalog/releases/download/v${VAULT_PLUGIN_CATALOG_VERSION}/vault-plugin-catalog-linux-${TARGETARCH} /usr/local/bin/vault-plugin-catalog
