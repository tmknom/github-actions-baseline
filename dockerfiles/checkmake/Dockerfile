FROM golang:1.13 as build-env

WORKDIR /app

ENV BUILDER_NAME=dummy
ENV BUILDER_EMAIL=dummy
ENV DEBIAN_FRONTEND=noninteractive

# hadolint ignore=DL3008
RUN set -x && \
    apt-get update -qq && \
    apt-get install -qq -y --no-install-recommends --no-install-suggests pandoc && \
    rm -rf /var/lib/apt/lists/* && \
    git clone https://github.com/mrtazz/checkmake /app && \
    make

FROM alpine:3.14.0

COPY --from=build-env /app/checkmake /usr/local/bin/checkmake

RUN set -x && \
    addgroup nonroot && \
    adduser -G nonroot -s /bin/sh -D nonroot

# checkov:skip=CKV_DOCKER_2:Healthcheck is not required as it is only used locally or in CI
USER nonroot
WORKDIR /work

ENTRYPOINT ["/usr/local/bin/checkmake"]
CMD ["--help"]
