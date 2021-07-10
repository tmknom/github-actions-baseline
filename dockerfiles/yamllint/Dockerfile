FROM python:3.9.5-alpine3.14

WORKDIR /app
COPY requirements.txt /app

RUN set -x && \
    addgroup nonroot && \
    adduser -G nonroot -s /bin/sh -D nonroot && \
    pip install --no-cache-dir -r /app/requirements.txt

# checkov:skip=CKV_DOCKER_2:Healthcheck is not required as it is only used locally or in CI
USER nonroot
WORKDIR /work

ENTRYPOINT ["/usr/local/bin/yamllint"]
CMD ["--help"]
