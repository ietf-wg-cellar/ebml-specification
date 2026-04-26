VERSION := 21
VERSION_UPDATE1 := 00
STATUS := draft-
OUTPUT := $(STATUS)ietf-cellar-ebml-$(VERSION)
OUTPUT_UPDATE1 := draft-ietf-cellar-ebml-update1-$(VERSION_UPDATE1)

XML2RFC_CALL := xml2rfc
MMARK_CALL := mmark

-include runtimes.mak

XML2RFC := $(XML2RFC_CALL) --v3
MMARK := $(MMARK_CALL)

all: $(OUTPUT).html $(OUTPUT).txt $(OUTPUT).xml $(OUTPUT_UPDATE1).html $(OUTPUT_UPDATE1).txt $(OUTPUT_UPDATE1).xml
	$(info RFC rendering has been tested with mmark version 2.2.8 and xml2rfc 2.46.0, please ensure these are installed and recent enough.)

$(OUTPUT).md: specification.markdown rfc_frontmatter.markdown rfc_backmatter.markdown EBMLSchema8794.xsd ebml_schema_example.xml
	cat rfc_frontmatter.markdown $< rfc_backmatter.markdown | sed "s/@BUILD_DATE@/$(shell date +'%F')/" > $(OUTPUT).md

$(OUTPUT_UPDATE1).md: update1/update1_frontmatter.markdown update1/update1.markdown update1/update1_backmatter.markdown EBMLSchema.xsd
	cat update1/update1_frontmatter.markdown update1/update1.markdown update1/update1_backmatter.markdown | sed -e "s/@BUILD_DATE@/$(shell date +'%F')/" \
	             -e "s/@BUILD_VERSION@/$(OUTPUT_UPDATE1)/" > $@

%.xml: %.md
	$(MMARK) $< > $@
	sed -i -e 's/<sourcecode type="xsd">/<sourcecode type="xml">/' $@

rfc8794.xml: $(OUTPUT).xml
	sed -e 's/<?xml version="1.0" encoding="utf-8"?>/<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE rfc SYSTEM "rfc2629-xhtml.ent">/' \
	-e "s/docName=\"8794\"/docName=\"$(OUTPUT)\" sortRefs=\"true\"/" \
	-e "s@\"http://www.w3.org/2001/XInclude\"@\"http://www.w3.org/2001/XInclude\" tocInclude=\"true\" symRefs=\"true\"@" \
	-e 's@<organization></organization>@@' \
	-e 's@<street></street>@@' \
	-e 's@<li>@<li><t>@' \
	-e 's@</li>@</t>\n</li>@' \
	-e 's@BCP 14@BCP\&nbsp;14@' \
	-e 's@<dd><t>@<dd>@' \
	-e 's@<date></date>@@' \
	-e 's@<back>@<back>\n<displayreference target="I-D.ietf-cellar-matroska" to="Matroska"/>@' \
	$< > $@

%.html: %.xml
	$(XML2RFC) --html $< -o $@

%.txt: %.xml
	$(XML2RFC) $< -o $@

clean:
	rm -f $(OUTPUT).txt $(OUTPUT).html $(OUTPUT).md $(OUTPUT).xml
	rm -f $(OUTPUT_UPDATE1).txt $(OUTPUT_UPDATE1).html $(OUTPUT_UPDATE1).md $(OUTPUT_UPDATE1).xml
