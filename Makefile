$(info RFC rendering has been tested with mmark version 1.3.4 and xml2rfc 2.5.1, please ensure these are installed and recent enough.)

VERSION := 01
STATUS := draft-
OUTPUT := $(STATUS)ietf-cellar-ebml-$(VERSION)

all: $(OUTPUT).html $(OUTPUT).txt

$(OUTPUT).md: specification.markdown rfc_frontmatter.markdown
	cat rfc_frontmatter.markdown $< > $(OUTPUT).md

$(OUTPUT).xml: $(OUTPUT).md
	mmark -xml2 -page $(OUTPUT).md > $(OUTPUT).xml

$(OUTPUT).html: $(OUTPUT).xml
	xml2rfc --html $(OUTPUT).xml -o $@

$(OUTPUT).txt: $(OUTPUT).xml
	xml2rfc $(OUTPUT).xml -o $@

clean:
	rm -f $(OUTPUT).txt $(OUTPUT).html $(OUTPUT).md $(OUTPUT).xml
