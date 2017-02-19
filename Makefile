$(info RFC rendering has been tested with mmark version 1.3.4 and xml2rfc 2.5.1, please ensure these are installed and recent enough.)

all: draft-ietf-cellar-ebml-01.html draft-ietf-cellar-ebml-01.txt

draft-ietf-cellar-ebml-01.md: specification.markdown rfc_frontmatter.markdown
	cat rfc_frontmatter.markdown $< > draft-ietf-cellar-ebml-01.md

draft-ietf-cellar-ebml-01.xml: draft-ietf-cellar-ebml-01.md
	mmark -xml2 -page draft-ietf-cellar-ebml-01.md > draft-ietf-cellar-ebml-01.xml

draft-ietf-cellar-ebml-01.html: draft-ietf-cellar-ebml-01.xml
	xml2rfc --html draft-ietf-cellar-ebml-01.xml -o $@

draft-ietf-cellar-ebml-01.txt: draft-ietf-cellar-ebml-01.xml
	xml2rfc draft-ietf-cellar-ebml-01.xml -o $@

clean:
	rm -f draft-ietf-cellar-ebml-01.txt draft-ietf-cellar-ebml-01.html draft-ietf-cellar-ebml-01.md draft-ietf-cellar-ebml-01.xml
