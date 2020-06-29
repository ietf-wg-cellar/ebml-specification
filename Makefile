VERSION := 18
STATUS := draft-
OUTPUT := $(STATUS)ietf-cellar-ebml-$(VERSION)

XML2RFC_CALL := xml2rfc
MMARK_CALL := mmark

-include runtimes.mak

XML2RFC := $(XML2RFC_CALL) --v3
MMARK := $(MMARK_CALL)

all: $(OUTPUT).html $(OUTPUT).txt $(OUTPUT).xml
	$(info RFC rendering has been tested with mmark version 2.1.1 and xml2rfc 2.30.0, please ensure these are installed and recent enough.)

$(OUTPUT).md: specification.markdown rfc_frontmatter.markdown rfc_backmatter.markdown EBMLSchema.xsd ebml_schema_example.xml
	cat rfc_frontmatter.markdown $< rfc_backmatter.markdown | sed "s/@BUILD_DATE@/$(shell date +'%F')/" > $(OUTPUT).md

%.xml: %.md
	$(MMARK) $< > $@
	sed -i -e 's/<sourcecode type="xsd">/<sourcecode type="xml">/' $@

rfc8794.xml: $(OUTPUT).xml
	sed -e 's/<?xml version="1.0" encoding="utf-8"?>/<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE rfc SYSTEM "rfc2629-xhtml.ent">/' \
	-e "s/docName=\"8794\"/docName=\"$(OUTPUT)\"/" \
	-e 's@<organization></organization>@@' \
	-e 's@<street></street>@@' \
	-e 's@BCP 14@BCP\&nbsp;14@' \
	-e 's@<dd><t>@<dd>@' \
	$< | \
	awk 1 RS='</t>\n</dd>' ORS='</dd>' | head -n -1 > $@

%.html: rfc8794.xml
	$(XML2RFC) --html $< -o $@

%.txt: rfc8794.xml
	$(XML2RFC) $< -o $@

clean:
	rm -f $(OUTPUT).txt $(OUTPUT).html $(OUTPUT).md $(OUTPUT).xml
