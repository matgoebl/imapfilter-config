FROM alpine:edge AS builder
RUN apk add --no-cache \
    --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
    imapfilter tini

WORKDIR /
COPY ./lua/ /lua/
COPY entrypoint.sh /entrypoint.sh
COPY config.lua.example /config.lua

ARG BUILDTAG=unknown
ENV BUILDTAG=${BUILDTAG}
RUN echo "${BUILDTAG}" > /buildtag

WORKDIR /

ENTRYPOINT ["/entrypoint.sh"]
