ARG CONSUL_VERSION=1.21.3
ARG GO_VERSION=1.23.10
ARG NODE_VERSION=18

# Stage 0: Clone the consul repository
ARG ALPINE_VERSION=3.13
FROM --platform=$BUILDPLATFORM alpine:${ALPINE_VERSION} AS stage0
RUN apk add --no-cache git
ARG CONSUL_VERSION
RUN git clone --depth=1 --branch=v${CONSUL_VERSION} --single-branch https://github.com/hashicorp/consul.git /consul
WORKDIR /consul

# Stage 1: Build the UI
FROM --platform=$BUILDPLATFORM node:${NODE_VERSION}-alpine AS stage1
RUN apk add --no-cache bash git patch make go
RUN npm install -g corepack && corepack disable && corepack enable
COPY --from=stage0 /consul /consul
WORKDIR /consul
RUN --mount=type=cache,target=/root/.yarn/ \
    --mount=type=cache,target=/root/.cache/yarn \
    --mount=type=cache,target=/usr/local/share/.cache/yarn \
<<EOF
    make ui-regen
EOF

# Stage 2: Build the consul binary
FROM --platform=$BUILDPLATFORM golang:${GO_VERSION}-alpine AS stage2
RUN apk add --no-cache bash git patch

# Copy the consul source code from the previous stage
COPY --link --from=stage0 /consul /consul
COPY --link --from=stage1 /consul/agent/uiserver/ /consul/agent/uiserver/
WORKDIR /consul

# Replace the go-discover dependency with the socheatsok78-lab version
RUN echo "replace github.com/hashicorp/go-discover => github.com/socheatsok78-lab/go-discover go-netaddrs" >> go.mod

# Build the consul binary
ARG TARGETARCH
ARG GITHUB_REPOSITORY_OWNER=soramitsukhmer-lab
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
<<EOF
    go mod tidy
    # (cd api && go mod tidy)
    # (cd sdk && go mod tidy)

    GIT_IMPORT="github.com/hashicorp/consul/version"
    GIT_COMMIT=$(git rev-parse --short HEAD)
    GIT_COMMIT_YEAR=$(git show -s --format=%cd --date=format:%Y HEAD)
    GIT_DIRTY=$(test -n "`git status --porcelain`" && echo "+CHANGES" || true)
    GIT_DIRTY=${GIT_DIRTY}${GITHUB_REPOSITORY_OWNER:+"+${GITHUB_REPOSITORY_OWNER}"}
    DATE_FORMAT="%Y-%m-%dT%H:%M:%SZ"
    GIT_DATE=$(date -u +${DATE_FORMAT})

    GOTAGS="consul ui"
    GOLDFLAGS="-w -s"
    GOLDFLAGS="${GOLDFLAGS} -X ${GIT_IMPORT}.GitCommit=${GIT_COMMIT}${GIT_DIRTY}"
    GOLDFLAGS="${GOLDFLAGS} -X ${GIT_IMPORT}.BuildDate=${GIT_DATE}"
    for GOARCH in amd64 arm64; do
        mkdir -p ./pkg/bin/linux_${GOARCH}
        (set -x; CGO_ENABLED=0 GOOS=linux GOARCH=${GOARCH} go build -o ./pkg/bin/linux_${GOARCH} -tags "${GOTAGS}" -ldflags "${GOLDFLAGS}" .)
    done
EOF

# Extras

# https://github.com/socheatsok78/go-discover-dockerswarm
FROM --platform=$BUILDPLATFORM golang:${GO_VERSION}-alpine AS discover-dockerswarm
ADD https://github.com/socheatsok78/go-discover-dockerswarm.git#main /go-discover-dockerswarm
WORKDIR /go-discover-dockerswarm/cmd
RUN go build -o /bin/discover-dockerswarm . \
    && chmod u+s /bin/discover-dockerswarm

# Final stage
FROM hashicorp/consul:${CONSUL_VERSION}
ARG TARGETARCH
COPY --from=stage2 /consul/pkg/bin/linux_${TARGETARCH}/consul /bin/consul
COPY --from=discover-dockerswarm /bin/discover-dockerswarm /bin/discover-dockerswarm
