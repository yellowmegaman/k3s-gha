FROM alpine:3.11.3

LABEL \
  "name"="GHA k3s" \
  "homepage"="https://github.com/marketplace/actions/gha-k3s" \
  "repository"="https://github.com/insolar/gha-k3s"

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && \
  apk add --no-cache curl bash docker

ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
