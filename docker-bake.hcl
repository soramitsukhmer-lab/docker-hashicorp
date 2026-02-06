variable "GITHUB_REPOSITORY_OWNER" {
  default = "soramitsukhmer-lab"
}

target "docker-metadata-action" {}
target "github-metadata-action" {}

target "shared-tools" {
  contexts = {
    "go-discover-dockerswarm" = "docker-image://ghcr.io/socheatsok78-lab/go-discover-dockerswarm:latest"
    "go-discover" = "docker-image://ghcr.io/socheatsok78-lab/go-discover:latest"
    "go-netaddrs" = "docker-image://ghcr.io/socheatsok78-lab/go-netaddrs:latest"
  }
}

group "default" {
  targets = [
    "consul",
    "consul-node-init",
    "vault",
  ]
}

# --------------------------------------------------
# HashiCorp Consul
#--------------------------------------------------

variable "CONSUL_VERSIONS" {
  type = list(string)
  default = [
    "latest",
    "1.21.3",
    "1.21.4",
    "1.21.5",
  ]
}

target "consul" {
  matrix = {
    version = CONSUL_VERSIONS
  }
  name = "consul_${sanitize(version)}"
  inherits = [
    "docker-metadata-action",
    "github-metadata-action",
    "shared-tools",
  ]
  context = "consul/${version}"
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
  labels = {
    "org.opencontainers.image.description" = "Consul is a distributed, highly available, and data center aware solution to connect and configure applications across dynamic, distributed infrastructure."
    "org.opencontainers.image.version" = version
  }
  tags = [
    "ghcr.io/${GITHUB_REPOSITORY_OWNER}/consul:${version}"
  ]
}

target "consul-node-init" {
  inherits = [
    "docker-metadata-action",
    "github-metadata-action",
  ]
  context = "consul-node-init"
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
  tags = [ "ghcr.io/${GITHUB_REPOSITORY_OWNER}/consul-node-init:latest" ]
}

# --------------------------------------------------
# HashiCorp Vault
#--------------------------------------------------

variable "VAULT_VERSIONS" {
  type = list(string)
  default = [
    "latest",
    "1.17.6",
    "1.20.0",
    "1.20.1",
    "1.20.2",
    "1.20.3",
    "1.20.4",
  ]
}

target "vault" {
  matrix = {
    version = VAULT_VERSIONS
  }
  name = "vault_${sanitize(version)}"
  inherits = [
    "docker-metadata-action",
    "github-metadata-action",
    "shared-tools",
  ]
  context = "vault/${version}"
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
  labels = {
    "org.opencontainers.image.description" = "A tool for secrets management, encryption as a service, and privileged access management"
    "org.opencontainers.image.version" = version
  }
  tags = [
    "ghcr.io/${GITHUB_REPOSITORY_OWNER}/vault:${version}"
  ]
}
