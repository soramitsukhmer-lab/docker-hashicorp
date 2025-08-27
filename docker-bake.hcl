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

# --------------------------------------------------
# HashiCorp Consul
#--------------------------------------------------

variable "CONSUL_VERSIONS" {
  type = list(string)
  default = [
    "latest",
    // "1.21.3",
    "1.21.4",
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
  context = "consul/${version}"
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
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
    # "1.20.0",
    # "1.20.1",
    "1.20.2",
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
  context = "vault/${version}"
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
  tags = [
    "ghcr.io/${GITHUB_REPOSITORY_OWNER}/vault:${version}"
  ]
}
