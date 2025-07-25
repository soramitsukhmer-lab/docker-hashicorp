variable "GITHUB_REPOSITORY_OWNER" {
  default = "soramitsukhmer-lab"
}

target "docker-metadata-action" {}
target "github-metadata-action" {}

group "default" {
  targets = [
    "consul",
    "consul-node-init",
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

target "consul-dev" {
  matrix = {
    version = CONSUL_VERSIONS
  }
  name = "consul_${replace(version, ".", "_")}_dev"
  context = "consul/v${version}"
  tags = [
      "ghcr.io/${GITHUB_REPOSITORY_OWNER}/consul:${version}-dev"
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
    "1.20.0",
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
  context = "vault/v${version}"
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
  context = "vault/v${version}"
  tags = [
      "ghcr.io/${GITHUB_REPOSITORY_OWNER}/vault:${version}-dev"
  ]
}
