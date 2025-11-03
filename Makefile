SHELL:=/bin/sh

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show the help messages
        @grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort -k 1,1 | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


.PHONY: dbshell
dbshell:
	docker compose exec db psql -U ttmobile

.PHONY: format
format:
	mix format mix.exs "lib/**/*.{ex,exs}" "test/**/*.{ex,exs}"
