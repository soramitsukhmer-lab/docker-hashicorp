variable "GITHUB_REPOSITORY" {
  default = "soramitsukhmer-lab/dockerswarm-hashicorp-images"
}

group "default" {
  targets = [
    "consul",
    "consul-init",
  ]
}

target "oci" {
  labels = {
    "org.opencontainers.image.source" = "https://github.com/${GITHUB_REPOSITORY}"
    "org.opencontainers.image.url" = "https://github.com/${GITHUB_REPOSITORY}"
  }
}

target "consul" {
  name = "consul-${replace(version, ".", "-")}"
  inherits = [ "oci" ]
  matrix = {
    "version" = [
      "latest",
      "1.21",
    ]
  }
  context = "consul"
  args = {
    "CONSUL_VERSION" = version
  }
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
  tags = [ "ghcr.io/soramitsukhmer-lab/consul:${version}" ]
}

target "consul-init" {
  inherits = [ "oci" ]
  context = "consul-init"
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
  tags = [ "ghcr.io/soramitsukhmer-lab/consul-init:latest" ]
}

target "consul-auto-discover" {
  inherits = [ "oci" ]
  context = "consul-auto-discover"
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
  tags = [ "ghcr.io/soramitsukhmer-lab/consul-auto-discover:latest" ]
}
