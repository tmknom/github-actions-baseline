FROM node:16.3.0-alpine3.13

WORKDIR /app
COPY package.json /app

RUN set -x && \
    addgroup nonroot && \
    adduser -G nonroot -s /bin/sh -D nonroot && \
    npm install && \
    npm cache clean --force

# checkov:skip=CKV_DOCKER_2:Healthcheck is not required as it is only used locally or in CI
USER nonroot
WORKDIR /work
ENV PATH $PATH:/app/node_modules/.bin
ENV NODE_PATH /app/node_modules

ENTRYPOINT ["/app/node_modules/.bin/remark"]
CMD ["--help"]
