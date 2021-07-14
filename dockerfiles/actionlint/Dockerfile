FROM golang:1.16 as build-env

WORKDIR /app

ENV VERSION=1.4.1
ENV TAR_BALL=actionlint_"${VERSION}"_linux_amd64.tar.gz
ENV BASE_URL=https://github.com/rhysd/actionlint/releases/download
ENV URL="${BASE_URL}"/v"${VERSION}"/"${TAR_BALL}"

RUN set -x && \
    curl -fsSL "${URL}" -o "${TAR_BALL}" && \
    tar -zxvf "${TAR_BALL}"

FROM alpine:3.14.0

COPY --from=build-env /app/actionlint /usr/local/bin/actionlint

RUN set -x && \
    addgroup nonroot && \
    adduser -G nonroot -s /bin/sh -D nonroot

# checkov:skip=CKV_DOCKER_2:Healthcheck is not required as it is only used locally or in CI
USER nonroot
WORKDIR /work

ENTRYPOINT ["/usr/local/bin/actionlint"]
