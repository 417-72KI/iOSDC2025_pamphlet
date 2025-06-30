.SILENT:

FILENAME=manuscript

.PHONY: pdf
pdf: html
	"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
		--headless \
		--disable-gpu \
		--print-to-pdf=output/$(FILENAME).pdf \
		--no-pdf-header-footer \
		output/$(FILENAME).html
	rm output/$(FILENAME).html

.PHONY: html
html: lint
	pandoc $(FILENAME).md -s \
	-o output/$(FILENAME).html \
	-c css/github.css \
	--highlight-style espresso \
	-f gfm

.PHONY: lint
lint:
	textlint --fix .
	textlint .

.PHONY: setup
setup:
	brew install pandoc
	npm install -g textlint \
		textlint-filter-rule-comments \
		textlint-filter-rule-allowlist \
		textlint-rule-no-dropping-the-ra \
		textlint-rule-preset-ja-spacing \
		textlint-rule-preset-ja-technical-writing \
		textlint-rule-preset-ai-writing
