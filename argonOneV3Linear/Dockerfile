ARG BUILD_FROM=ghcr.io/hassio-addons/base/aarch64:17.2.5
# hadolint ignore=DL3006
FROM $BUILD_FROM

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV LANG C.UTF-8
WORKDIR /data

# Alpine 3.21 (base ≥ 17.0.0) ships libgpiod 2.2-r1 in community, which provides
# gpiomon with v2 CLI syntax (-c/-e/-n flags). Alpine 3.20 and earlier only had
# libgpiod 1.6.x — v2 syntax would silently fail there.
# i2c-tools: was 4.2-r0 on old Alpine 3.13 base; 4.3-r3 on Alpine 3.21 (unpinned
# to avoid breakage if a patch revision is released).
# hadolint ignore=DL3018
RUN apk add --no-cache i2c-tools libgpiod

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
