FROM node:16.3.0-alpine3.13

WORKDIR /app
COPY package.json /app

# hadolint ignore=DL3018
RUN set -x && \
    addgroup nonroot && \
    adduser -G nonroot -s /bin/sh -D nonroot && \
    apk add --no-cache git && \
    npm install && \
    npm cache clean --force

USER nonroot
WORKDIR /work
ENV PATH $PATH:/app/node_modules/.bin

ENTRYPOINT ["/app/node_modules/.bin/standard-version"]
CMD ["--help"]
