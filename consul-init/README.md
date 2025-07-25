## About
A init container for Consul that initializes the Consul configuration and prepares the environment for the Consul server to run.

What it does:
- Automatically assign `bind_addr`, `client_addr`, and `advertise_addr` based on the host network.

## Usage

```yml
services:
  consul:
    image: ghcr.io/soramitsukhmer-lab/consul:dev
    command: agent -server -ui -bootstrap-expect=1
    ports:
      - "8300:8300/tcp" # Server RPC
      - "8301:8301/tcp" # LAN Serf
      - "8301:8301/udp" # LAN Serf
      # - "8302:8302/tcp" # WAN Serf (Disabled by default)
      # - "8302:8302/udp" # WAN Serf (Disabled by default)
      - "8500:8500"     # HTTP
      # - "8501:8501/tcp" # HTTPS (Disabled by default)
      # - "8502:8502/tcp" # gRPC
      # - "8503:8503/tcp" # gRPC TLS
      - "8600:8600/tcp" # DNS
      - "8600:8600/udp" # DNS
    volumes:
      # - data:/consul/data
      - config:/consul/config
    depends_on:
      - consul-init

  consul-init:
    image: ghcr.io/soramitsukhmer-lab/consul-init:dev
    networks:
      consul-init:
    volumes:
      - config:/consul/config
    deploy:
      mode: global-job

volumes:
  data:
  config:

networks:
  consul:
  consul-init:
    name: host
    external: true
```
