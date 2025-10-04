FROM golang:1-alpine3.22 AS builder

# Add bash to the list of installed packages
RUN apk add --no-cache git ca-certificates build-base su-exec olm-dev bash

COPY . /build
WORKDIR /build

# Make build.sh executable before running it
RUN chmod +x build.sh && ./build.sh

FROM alpine:3.22

ENV UID=1337 \
    GID=1337 \
    RAILWAY_RUN_UID=0

RUN apk add --no-cache ffmpeg su-exec ca-certificates olm bash jq yq-go curl

COPY --from=builder /build/mautrix-meta /usr/bin/mautrix-meta
COPY --from=builder /build/docker-run.sh /docker-run.sh

RUN chmod +x /docker-run.sh

CMD ["/docker-run.sh"]
