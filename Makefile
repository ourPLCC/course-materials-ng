VENV = .venv
PIP = $(VENV)/bin/pip
MKDOCS = $(VENV)/bin/mkdocs

.PHONY: install serve build clean

install:
	python3 -m venv $(VENV)
	$(PIP) install -r requirements.txt

serve:
	$(MKDOCS) serve

build:
	$(MKDOCS) build --strict

clean:
	rm -rf $(VENV) site
