FROM node:16.3.0-alpine3.13

WORKDIR /app
COPY package.json /app

RUN set -x && \
    npm install && \
    npm cache clean --force

USER node
WORKDIR /work
ENV PATH $PATH:/app/node_modules/.bin

ENTRYPOINT ["/app/node_modules/.bin/prettier"]
CMD ["--help"]
