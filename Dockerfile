FROM alpine:3.11.3

LABEL \
  "name"="GHA k3s" \
  "homepage"="https://github.com/marketplace/actions/gha-k3s" \
  "repository"="https://github.com/insolar/gha-k3s"

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && \
  apk add --no-cache curl bash docker && \
  curl -L -s --create-dirs https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
  chmod +x /usr/local/bin/kubectl

ADD entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
