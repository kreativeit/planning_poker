.PHONY: help

ORG_NAME ?= kreativeit
APP_NAME ?= planning_poker
APP_VSN ?= `grep 'version:' mix.exs | cut -d '"' -f2`
BUILD ?= `git rev-parse --short HEAD`

help:
	@echo "$(APP_NAME):$(APP_VSN)-$(BUILD)"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build the Docker image
	docker build --build-arg APP_NAME=$(APP_NAME) \
		--build-arg APP_VSN=$(APP_VSN) \
		-t ghcr.io/$(ORG_NAME)/$(APP_NAME):$(APP_VSN)-$(BUILD) \
		-t ghcr.io/$(ORG_NAME)/$(APP_NAME):latest .

push: build ## Push the Docker image
	docker push ghcr.io/$(ORG_NAME)/$(APP_NAME):$(APP_VSN)-$(BUILD)
	docker push ghcr.io/$(ORG_NAME)/$(APP_NAME):latest

test: build ## Run the tests
	docker run ghcr.io/$(ORG_NAME)/$(APP_NAME):$(APP_VSN)-$(BUILD)

run: ## Run the app in Docker
	docker run --env-file config/docker.env \
		--expose 80 -p 80:80 \
		--rm -it $(APP_NAME):latest