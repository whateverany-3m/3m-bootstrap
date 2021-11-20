ARG SOURCE_GROUP
ARG SOURCE_REGISTRY
ARG SOURCE_IMAGE
ARG SOURCE_VERSION

FROM $SOURCE_REGISTRY$SOURCE_GROUP$SOURCE_IMAGE:$SOURCE_VERSION

COPY src/rootfs/ /

RUN set -x ;\
  echo "INFO: begin RUN" ;\
  /sbin/apk add --no-cache \
    git=2.32.0-r0 \
    make=4.3-r0 \
    busybox=1.33.1-r3 \
  ;\
  /bin/busybox --install ;\
  echo "INFO: end RUN"

