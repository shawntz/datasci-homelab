.PHONY: help build build-multi push up down logs clean setup-buildx

help: ## Show this help message
	@echo "DataSci Homelab - Make commands"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build image for local platform
	docker build -t datasci-homelab:local .

build-multi: ## Build multi-platform image (requires buildx)
	./scripts/build-multiplatform.sh

push: ## Build and push multi-platform image to Docker Hub and GHCR
	./scripts/push-to-registries.sh

up: ## Start services with docker compose
	docker compose up -d

down: ## Stop services with docker compose
	docker compose down

logs: ## View logs from docker compose
	docker compose logs -f

clean: ## Remove local images and containers
	docker compose down -v
	docker rmi datasci-homelab:local || true

setup-buildx: ## Setup Docker buildx for multi-platform builds
	docker buildx create --name datasci-homelab-builder --driver docker-container --bootstrap || true
	docker buildx use datasci-homelab-builder
