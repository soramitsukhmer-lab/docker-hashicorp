target "default" {
  matrix = {
    version = [
      "1.21.3",
    ]
  }
  name = "consul_${replace(version, ".", "_")}"
  context = "v${version}"
  tags = [
      "harbor.sorakh.io/soramitsukhmer-lab/consul:${version}-dev"
  ]
}
