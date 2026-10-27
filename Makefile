PY      ?= .venv/bin
DBT     := $(PY)/dbt
DOCS_PORT ?= 8089

.PHONY: setup deps build test docs serve-docs freshness report lint dirty clean

setup:  ## create .venv (Python 3.12) and install pinned dependencies
	/opt/homebrew/bin/python3.12 -m venv .venv || python3.12 -m venv .venv
	$(PY)/pip install -r requirements.txt
	$(MAKE) deps

deps:
	$(DBT) deps

build: deps  ## models + tests, in DAG order
	$(DBT) build

test:  ## run data tests only (requires a previous make build)
	$(DBT) test

freshness:
	$(DBT) source freshness

docs:  ## generate the dbt docs site into target/
	$(DBT) docs generate

serve-docs: docs
	$(DBT) docs serve --port $(DOCS_PORT) --no-browser

report: build  ## regenerate reports/exceptions_summary.md from the mart
	$(PY)/python scripts/exceptions_summary.py

lint:  ## ruff for Python, sqlfluff (dbt templater) for SQL
	$(PY)/ruff check scripts
	$(PY)/ruff format --check scripts
	$(PY)/sqlfluff lint models

dirty:  ## build on the dirty extracts; test failures are expected
	$(PY)/python scripts/make_dirty_extracts.py
	# run, then test separately: `dbt build` would skip models downstream of a failing test
	RAW_DIR=dirty_extracts $(DBT) run --target dirty
	RAW_DIR=dirty_extracts $(DBT) test --target dirty || true

clean:
	rm -rf target logs dbt_packages dirty_extracts *.duckdb
