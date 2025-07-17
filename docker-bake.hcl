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
  tags = [ "ghcr.io/soramitsukhmer-lab/consul:${version}" ]
}
target "consul-init" {
  context = "consul-init"
  tags = [ "ghcr.io/soramitsukhmer-lab/consul-init:latest" ]
}
