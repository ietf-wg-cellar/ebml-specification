$(info RFC rendering has been tested with mmark version 1.3.4 and xml2rfc 2.5.1, please ensure these are installed and recent enough.)

all: draft-lhomme-cellar-ebml-00.html draft-lhomme-cellar-ebml-00.txt
	
draft-lhomme-cellar-ebml-00.html: specification.markdown
	cat rfc_frontmatter.markdown "$<" > merged.md
	mmark -xml2 -page merged.md > draft-lhomme-cellar-ebml-00.xml
	xml2rfc --html draft-lhomme-cellar-ebml-00.xml -o "$@"

draft-lhomme-cellar-ebml-00.txt: specification.markdown
	cat rfc_frontmatter.markdown "$<" > merged.md
	mmark -xml2 -page merged.md > draft-lhomme-cellar-ebml-00.xml
	xml2rfc draft-lhomme-cellar-ebml-00.xml -o "$@"

clean:
	rm -f draft-lhomme-cellar-ebml-00.txt draft-lhomme-cellar-ebml-00.html merged.md draft-lhomme-cellar-ebml-00.xml
