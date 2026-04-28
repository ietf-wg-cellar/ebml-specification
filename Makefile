VERSION_EBML := 21
STATUS_EBML := draft-
OUTPUT_EBML := $(STATUS_EBML)ietf-cellar-ebml-$(VERSION_EBML)
VERSION_CORRECTION := 01
STATUS_CORRECTION := draft-
OUTPUT_CORRECTION := $(STATUS_EBML)ietf-cellar-rfc8794-corrections-$(VERSION_CORRECTION)

XML2RFC_CALL := xml2rfc
MMARK_CALL := mmark

-include runtimes.mak

XML2RFC := $(XML2RFC_CALL) --v3
MMARK := $(MMARK_CALL)

all: ebml ebml_corrections
	$(info RFC rendering has been tested with mmark version 2.2.8 and xml2rfc 2.46.0, please ensure these are installed and recent enough.)

ebml: rfc8794.xml $(OUTPUT_EBML).html $(OUTPUT_EBML).txt $(OUTPUT_EBML).tmp_xml
ebml_corrections: $(OUTPUT_CORRECTION).html $(OUTPUT_CORRECTION).txt $(OUTPUT_CORRECTION).tmp_xml

$(OUTPUT_EBML).md: specification.markdown rfc_frontmatter.markdown rfc_backmatter.markdown EBMLSchema.xsd ebml_schema_example.xml
	cat rfc_frontmatter.markdown $< rfc_backmatter.markdown | sed "s/@BUILD_DATE@/$(shell date +'%F')/" > $@

$(OUTPUT_CORRECTION).md: corrections.markdown rfc_frontmatter_corrections.markdown rfc_backmatter_corrections.markdown EBMLSchema.xsd
	cat rfc_frontmatter_corrections.markdown $< rfc_backmatter_corrections.markdown | sed -e "s/@BUILD_DATE@/$(shell date +'%F')/" -e "s/@BUILD_VERSION@/$(OUTPUT_CORRECTION)/" > $@

%.tmp_xml: %.md
	$(MMARK) $< > $@

$(OUTPUT_EBML).xml: $(OUTPUT_EBML).tmp_xml
	sed -e 's/<?xml version="1.0" encoding="utf-8"?>/<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE rfc SYSTEM "rfc2629-xhtml.ent">/' \
	-e "s/docName=\"8794\"/docName=\"$(OUTPUT_EBML)\" sortRefs=\"true\"/" \
	-e "s@\"http://www.w3.org/2001/XInclude\"@\"http://www.w3.org/2001/XInclude\" tocInclude=\"true\" symRefs=\"true\"@" \
	-e 's/<sourcecode type="xsd">/<sourcecode type="xml">/' \
	-e 's@<organization></organization>@@' \
	-e 's@<street></street>@@' \
	-e 's@<li>@<li><t>@' \
	-e 's@</li>@</t>\n</li>@' \
	-e 's@BCP 14@BCP\&nbsp;14@' \
	-e 's@<dd><t>@<dd>@' \
	-e 's@<date></date>@@' \
	-e 's@<back>@<back>\n<displayreference target="I-D.ietf-cellar-matroska" to="Matroska"/>@' \
	$< > $@

$(OUTPUT_CORRECTION).xml: $(OUTPUT_CORRECTION).tmp_xml
	sed -e 's/<?xml version="1.0" encoding="utf-8"?>/<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE rfc SYSTEM "rfc2629-xhtml.ent">/' \
	-e "s/docName=\"87940\"/docName=\"$(OUTPUT_CORRECTION)\" sortRefs=\"true\"/" \
	-e "s@\"http://www.w3.org/2001/XInclude\"@\"http://www.w3.org/2001/XInclude\" tocInclude=\"true\" symRefs=\"true\"@" \
	-e 's/<sourcecode type="xsd">/<sourcecode type="xml">/' \
	-e 's@<organization></organization>@@' \
	-e 's@<street></street>@@' \
	-e 's@<li>@<li><t>@' \
	-e 's@</li>@</t>\n</li>@' \
	-e 's@BCP 14@BCP\&nbsp;14@' \
	-e 's@<dd><t>@<dd>@' \
	-e 's@<date></date>@@' \
	$< | \
	awk 1 RS='</t>\n</dd>' ORS='</dd>' | head -n -1 > $@

rfc8794.xml: $(OUTPUT_EBML).xml
	cp $< $@

%.html: %.xml
	$(XML2RFC) --html $< -o $@

%.txt: %.xml
	$(XML2RFC) $< -o $@

clean:
	rm -f $(OUTPUT_EBML).html $(OUTPUT_EBML).txt $(OUTPUT_EBML).xml $(OUTPUT_EBML).tmp_xml $(OUTPUT_EBML).md
	rm -f rfc8794.xml
	rm -f $(OUTPUT_CORRECTION).html $(OUTPUT_CORRECTION).txt $(OUTPUT_CORRECTION).xml $(OUTPUT_CORRECTION).tmp_xml $(OUTPUT_CORRECTION).md
