FROM johannweging/base-alpine:latest
ARG LEANOTE_VERSION

ENV LEANOTE_VERSION=${LEANOTE_VERSION} GOPATH=/go

RUN set -x \
&& apk add --update --no-cache bash grep mongodb mongodb-tools \
&& curl -SL https://downloads.sourceforge.net/project/leanote-bin/${LEANOTE_VERSION}/leanote-linux-amd64-v${LEANOTE_VERSION}.bin.tar.gz > /leanote.tar.gz \
&& tar -xvf leanote.tar.gz \
&& rm -f /leanote.tar.gz

RUN set -x \
&& mkdir -p /go/src/github.com/leanote \
&& ln -sf /leanote /go/src/github.com/leanote/leanote \
&& ln -sf /leanote/bin/src/github.com/revel/ /go/src/github.com/revel

RUN set -x \
&& createuser leanote

ADD rootfs /

RUN set -x \
&& chmod +x /run.sh

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/run.sh"]
EXPOSE 9000
