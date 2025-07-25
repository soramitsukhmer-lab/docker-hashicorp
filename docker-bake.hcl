variable "MATRIX_VERSIONS" {
  type = list(string)
  default = [
    "1.21.3",
  ]
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
      "harbor.sorakh.io/soramitsukhmer-lab/consul:${version}"
  ]
}

target "dev" {
  matrix = {
    version = MATRIX_VERSIONS
  }
  name = "consul_${replace(version, ".", "_")}_dev"
  context = "v${version}"
  tags = [
      "harbor.sorakh.io/soramitsukhmer-lab/consul:${version}-dev"
  ]
}
