$(info RFC rendering has been tested with mmark version 2.1.1 and xml2rfc 2.30.0, please ensure these are installed and recent enough.)

VERSION := 12
STATUS := draft-
OUTPUT := $(STATUS)ietf-cellar-ebml-$(VERSION)
XML2RFC := xml2rfc --v3
# export PATH=".:$PATH"

all: $(OUTPUT).html $(OUTPUT).txt $(OUTPUT).xml

$(OUTPUT).md: specification.markdown rfc_frontmatter.markdown rfc_backmatter.markdown EBMLSchema.xsd ebml_schema_example.xml
	cat rfc_frontmatter.markdown $< rfc_backmatter.markdown > $(OUTPUT).md

%.xml: %.md
	./mmark $< > $@

%.html: %.xml
	$(XML2RFC) --html $< -o $@

%.txt: %.xml
	$(XML2RFC) $< -o $@

clean:
	rm -f $(OUTPUT).txt $(OUTPUT).html $(OUTPUT).md $(OUTPUT).xml
