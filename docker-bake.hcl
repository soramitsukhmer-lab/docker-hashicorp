group "default" {
  targets = [
    "consul",
    "consul-init",
  ]
}

target "consul" {
  name = "consul-${replace(version, ".", "-")}"
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
  context = "consul-init"
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
  tags = [ "ghcr.io/soramitsukhmer-lab/consul-init:latest" ]
}
