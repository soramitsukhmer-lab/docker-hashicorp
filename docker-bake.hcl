variable "MATRIX_VERSIONS" {
  type = list(string)
  default = [
    "1.21.3",
  ]
}

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
  ]
}

target "consul" {
  matrix = {
    version = MATRIX_VERSIONS
  }
  inherits = [
    "docker-metadata-action",
    "github-metadata-action",
  ]
  name = "consul_${replace(version, ".", "_")}"
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
  tags = [ "ghcr.io/soramitsukhmer-lab/consul-init:latest" ]
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
  tags = [ "ghcr.io/soramitsukhmer-lab/consul-auto-discover:latest" ]
}

group "dev" {
  targets = [
    "consul-dev",
  ]
}

target "consul-dev" {
  matrix = {
    version = MATRIX_VERSIONS
  }
  name = "consul_${replace(version, ".", "_")}_dev"
  context = "consul/v${version}"
  tags = [
      "ghcr.io/${GITHUB_REPOSITORY_OWNER}/consul:${version}-dev"
  ]
}
