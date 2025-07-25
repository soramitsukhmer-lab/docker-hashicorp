variable "GITHUB_REPOSITORY_OWNER" {
  default = "soramitsukhmer-lab"
}

target "docker-metadata-action" {}
target "github-metadata-action" {}

group "default" {
  targets = [
    "consul",
    "consul-init",
    "consul-auto-discover",
    "vault",
  ]
}

group "dev" {
  targets = [
    "consul-dev",
    "vault-dev",
  ]
}

# --------------------------------------------------
# HashiCorp Consul
#--------------------------------------------------

variable "CONSUL_VERSIONS" {
  type = list(string)
  default = [
    "1.21.3",
  ]
}

target "consul" {
  matrix = {
    version = CONSUL_VERSIONS
  }
  name = "consul_${replace(version, ".", "_")}"
  inherits = [
    "docker-metadata-action",
    "github-metadata-action",
  ]
  context = "consul/v${version}"
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
  tags = [
      "ghcr.io/${GITHUB_REPOSITORY_OWNER}/consul:${version}"
  ]
}

target "consul-init" {
  inherits = [
    "docker-metadata-action",
    "github-metadata-action",
  ]
  context = "consul-init"
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
  tags = [ "ghcr.io/${GITHUB_REPOSITORY_OWNER}/consul-init:latest" ]
}

target "consul-auto-discover" {
  inherits = [
    "docker-metadata-action",
    "github-metadata-action",
  ]
  context = "consul-auto-discover"
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
  tags = [ "ghcr.io/${GITHUB_REPOSITORY_OWNER}/consul-auto-discover:latest" ]
}

# --------------------------------------------------
# HashiCorp Vault
#--------------------------------------------------

variable "VAULT_VERSIONS" {
  type = list(string)
  default = [
    "1.20.0",
  ]
}

target "consul-dev" {
  matrix = {
    version = VAULT_VERSIONS
  }
  name = "consul_${replace(version, ".", "_")}_dev"
  context = "consul/v${version}"
  tags = [
      "ghcr.io/${GITHUB_REPOSITORY_OWNER}/consul:${version}-dev"
  ]
}

target "vault" {
  matrix = {
    version = VAULT_VERSIONS
  }
  name = "vault_${replace(version, ".", "_")}"
  inherits = [
    "docker-metadata-action",
    "github-metadata-action",
  ]
  context = "v${version}"
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
  tags = [
      "ghcr.io/${GITHUB_REPOSITORY_OWNER}/vault:${version}"
  ]
}

target "vault-dev" {
  matrix = {
    version = VAULT_VERSIONS
  }
  name = "vault_${replace(version, ".", "_")}_dev"
  context = "v${version}"
  tags = [
      "ghcr.io/${GITHUB_REPOSITORY_OWNER}/vault:${version}-dev"
  ]
}
