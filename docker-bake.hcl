variable "MATRIX_VERSIONS" {
  type = list(string)
  default = [
    "1.21.3",
  ]
}

variable "GITHUB_REPOSITORY_OWNER" {
  default = "soramitsukhmer-lab"
}

target "default" {
  matrix = {
    version = MATRIX_VERSIONS
  }
  name = "consul_${replace(version, ".", "_")}"
  context = "v${version}"
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
  tags = [
      "ghcr.io/${GITHUB_REPOSITORY_OWNER}/consul:${version}"
  ]
}

target "dev" {
  matrix = {
    version = MATRIX_VERSIONS
  }
  name = "consul_${replace(version, ".", "_")}_dev"
  context = "v${version}"
  tags = [
      "ghcr.io/${GITHUB_REPOSITORY_OWNER}/consul:${version}-dev"
  ]
}
