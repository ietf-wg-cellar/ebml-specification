$(info RFC rendering has been tested with mmark version 1.3.4 and xml2rfc 2.5.1, please ensure these are installed and recent enough.)

all: draft-ietf-cellar-ebml-00.html draft-ietf-cellar-ebml-00.txt
	
draft-ietf-cellar-ebml-00.html: specification.markdown
	cat rfc_frontmatter.markdown "$<" > merged.md
	mmark -xml2 -page merged.md > draft-ietf-cellar-ebml-00.xml
	xml2rfc --html draft-ietf-cellar-ebml-00.xml -o "$@"

draft-ietf-cellar-ebml-00.txt: specification.markdown
	cat rfc_frontmatter.markdown "$<" > merged.md
	mmark -xml2 -page merged.md > draft-ietf-cellar-ebml-00.xml
	xml2rfc draft-ietf-cellar-ebml-00.xml -o "$@"

clean:
	rm -f draft-ietf-cellar-ebml-00.txt draft-ietf-cellar-ebml-00.html merged.md draft-ietf-cellar-ebml-00.xml
