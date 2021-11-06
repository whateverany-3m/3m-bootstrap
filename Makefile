DOCKER_COMPOSE_RUN := docker-compose run --rm
BUILD ?= 0
VERSION := 0.0.0
TARGET_SEMANTIC_VERSION := $(TARGET_VERSION)
TARGET_SEMANTIC_RC := $(TARGET_SEMANTIC_VERSION)-rc.$(TARGET_BUILD)
ENVFILE := .env

preaction: .env env-TARGET_REGISTRY env-TARGET_REGISTRY_TOKEN env-TARGET_REGISTRY_USER
	echo "INFO: Check /var/run/docker.sock"
	stat /var/run/docker.sock
	echo "INFO: docker login"
	echo "$(TARGET_REGISTRY_TOKEN)" | docker login --username $(TARGET_REGISTRY_USER) --password-stdin "$(TARGET_REGISTRY)"
.PHONY: preaction


runaction: .env env-SOURCE_GROUP env-SOURCE_IMAGE env-SOURCE_REGISTRY env-SOURCE_VERSION env-TARGET_GROUP env-TARGET_IMAGE env-TARGET_REGISTRY env-TARGET_SEMANTIC_RC env-TARGET_SEMANTIC_VERSION
	/usr/bin/docker build \
		--no-cache \
	  --build-arg SOURCE_GROUP=$(SOURCE_GROUP) \
	  --build-arg SOURCE_REGISTRY=$(SOURCE_REGISTRY) \
	  --build-arg SOURCE_IMAGE=$(SOURCE_IMAGE) \
	  --build-arg SOURCE_VERSION=$(SOURCE_VERSION) \
	  --tag $(TARGET_REGISTRY)$(TARGET_GROUP)$(TARGET_IMAGE):$(TARGET_SEMANTIC_RC) \
	  --tag $(TARGET_REGISTRY)$(TARGET_GROUP)$(TARGET_IMAGE):$(TARGET_SEMANTIC_VERSION) \
	  --file Dockerfile  \
	  .
	docker images
	docker push $(TARGET_REGISTRY)$(TARGET_GROUP)$(TARGET_IMAGE):$(TARGET_SEMANTIC_RC)
	docker push $(TARGET_REGISTRY)$(TARGET_GROUP)$(TARGET_IMAGE):$(TARGET_SEMANTIC_VERSION)
.PHONY: runaction

postaction: .env env-TARGET_REGISTRY
	echo "INFO: docker logout
	docker logout "${TARGET_REGISTRY}"
.PHONY: postaction

shell: .env env-DOCKER_COMPOSE_RUN
	$(DOCKER_COMPOSE_RUN) 3m /bin/sh
.PHONY: shell

shell-root: .env env-DOCKER_COMPOSE_RUN
	$(DOCKER_COMPOSE_RUN) -u root 3m /bin/sh
.PHONY: shell-root

.env: env-ENVFILE
	echo $(ENVFILE)

env-%:
	if [ "${$*}" = "" ] ; then echo "ERROR: $* is not set"; exit 1; fi
	echo "INFO: $*=${$*}"

