variable "VERSION" {
  default = ""
  validation {
    condition = VERSION != ""
    error_message = "The variable 'VERSION' must be set to a non-empty value."
  }
}

variable "GITHUB_REPOSITORY_OWNER" {
  default = "soramitsukhmer-lab"
}

target "docker-metadata-action" {}
target "github-metadata-action" {}

target "vault" {
  inherits = [
    "docker-metadata-action",
    "github-metadata-action",
  ]
  context = "${VERSION}"
  contexts = {
    "go-discover-dockerswarm" = "docker-image://ghcr.io/socheatsok78-lab/go-discover-dockerswarm:latest"
    "go-discover" = "docker-image://ghcr.io/socheatsok78-lab/go-discover:latest"
    "go-netaddrs" = "docker-image://ghcr.io/socheatsok78-lab/go-netaddrs:latest"
  }
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
  labels = {
    "org.opencontainers.image.description" = "A tool for secrets management, encryption as a service, and privileged access management"
    "org.opencontainers.image.version" = VERSION
  }
  tags = [
    "ghcr.io/${GITHUB_REPOSITORY_OWNER}/vault:${VERSION}"
  ]
}
