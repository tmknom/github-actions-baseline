FROM golang:1.16 as build-actionlint

WORKDIR /app

ENV VERSION=1.6.9
ENV TAR_BALL=actionlint_"${VERSION}"_linux_amd64.tar.gz
ENV BASE_URL=https://github.com/rhysd/actionlint/releases/download
ENV URL="${BASE_URL}"/v"${VERSION}"/"${TAR_BALL}"

RUN set -x && \
    curl -fsSL "${URL}" -o "${TAR_BALL}" && \
    tar -zxvf "${TAR_BALL}"

FROM golang:1.16 as build-shellcheck

WORKDIR /app

ENV VERSION=stable
ENV TAR_BALL=shellcheck-"${VERSION}".linux.x86_64.tar.xz
ENV BASE_URL=https://github.com/koalaman/shellcheck/releases/download
ENV URL="${BASE_URL}"/"${VERSION}"/"${TAR_BALL}"

# hadolint ignore=DL3008
RUN set -x && \
    apt-get update -qq && \
    apt-get install -qq -y --no-install-recommends --no-install-suggests xz-utils && \
    rm -rf /var/lib/apt/lists/* && \
    curl -fsSL "${URL}" -o "${TAR_BALL}" && \
    tar -Jxvf "${TAR_BALL}"

FROM alpine:3.14.0

COPY --from=build-actionlint /app/actionlint /usr/local/bin/actionlint
COPY --from=build-shellcheck /app/shellcheck-stable/shellcheck /usr/local/bin/shellcheck

RUN set -x && \
    addgroup nonroot && \
    adduser -G nonroot -s /bin/sh -D nonroot

# checkov:skip=CKV_DOCKER_2:Healthcheck is not required as it is only used locally or in CI
USER nonroot
WORKDIR /work

ENTRYPOINT ["/usr/local/bin/actionlint"]
