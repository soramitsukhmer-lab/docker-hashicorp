group "default" {
  targets = [
    "consul",
    "consul-init",
  ]
}

target "consul" {
  context = "consul"
  tags = [ "ghcr.io/soramitsukhmer-lab/consul:dev" ]
}
target "consul-init" {
  context = "consul-init"
  tags = [ "ghcr.io/soramitsukhmer-lab/consul-init:dev" ]
}
