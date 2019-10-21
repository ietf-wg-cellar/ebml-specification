$(info RFC rendering has been tested with mmark version 2.1.1 and xml2rfc 2.30.0, please ensure these are installed and recent enough.)

VERSION := 12
STATUS := draft-
OUTPUT := $(STATUS)ietf-cellar-ebml-$(VERSION)

XML2RFC_CALL := xml2rfc
MMARK_CALL := mmark

-include runtimes.mak

XML2RFC := $(XML2RFC_CALL) --v3
MMARK := $(MMARK_CALL)

all: $(OUTPUT).html $(OUTPUT).txt $(OUTPUT).xml

$(OUTPUT).md: specification.markdown rfc_frontmatter.markdown rfc_backmatter.markdown EBMLSchema.xsd ebml_schema_example.xml
	cat rfc_frontmatter.markdown $< rfc_backmatter.markdown > $(OUTPUT).md

%.xml: %.md
	$(MMARK) $< | sed 's|<sourcecode type="xml">|<artwork type="ascii-art">|g;s|<sourcecode type="xsd">|<artwork type="ascii-art">|g;s|</sourcecode>|</artwork>|g' > $@

%.html: %.xml
	$(XML2RFC) --html $< -o $@

%.txt: %.xml
	$(XML2RFC) $< -o $@

clean:
	rm -f $(OUTPUT).txt $(OUTPUT).html $(OUTPUT).md $(OUTPUT).xml
