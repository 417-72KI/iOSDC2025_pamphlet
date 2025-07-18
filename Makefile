.SILENT:

FILENAME=manuscript

.PHONY: pdf
pdf: html
	vivliostyle build output/$(FILENAME).html -m -o output/$(FILENAME).pdf
	rm -r output/$(FILENAME).html output/css

.PHONY: html
html: lint
	cp -r css output
	pandoc $(FILENAME).md -s \
	-o output/$(FILENAME).html \
	-c css/github.css \
	--highlight-style espresso \
	-f gfm

.PHONY: lint
lint:
	textlint --fix .
	textlint .

.PHONY: clean
clean:
	git clean -xf output

.PHONY: setup
setup:
	brew install pandoc
	npm install -g @vivliostyle/cli \
		textlint \
		textlint-filter-rule-comments \
		textlint-filter-rule-allowlist \
		textlint-rule-no-dropping-the-ra \
		textlint-rule-preset-ja-spacing \
		textlint-rule-preset-ja-technical-writing \
		textlint-rule-preset-ai-writing
