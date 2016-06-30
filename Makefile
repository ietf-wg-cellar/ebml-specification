$(info RFC rendering has been tested with mmark version 1.3.4 and xml2rfc 2.5.1, please ensure these are installed and recent enough.)

all: ebml_rfc.html draft-lhomme-cellar-ebml-00.txt
	
ebml_rfc.html: specification.markdown
	cat rfc_frontmatter.markdown "$<" > merged.md
	mmark -xml2 -page merged.md > ebml_rfc.xml
	xml2rfc --html ebml_rfc.xml -o "$@"

draft-lhomme-cellar-ebml-00.txt: specification.markdown
	cat rfc_frontmatter.markdown "$<" > merged.md
	mmark -xml2 -page merged.md > ebml_rfc.xml
	xml2rfc ebml_rfc.xml -o "$@"

clean:
	rm -f draft-lhomme-cellar-ebml-00.txt ebml_rfc.html merged.md ebml_rfc.xml
