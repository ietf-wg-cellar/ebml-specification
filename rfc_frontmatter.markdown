%%%
title = "Extensible Binary Meta Language"
abbrev = "EBML"
ipr= "trust200902"
area = "art"
workgroup = "cellar"
keyword = [""]

[seriesInfo]
name = "Internet-Draft"
stream = "IETF"
status = "standard"
value = "draft-ietf-cellar-ebml-15"

[[author]]
initials="S."
surname="Lhomme"
fullname="Steve Lhomme"
  [author.address]
  email="slhomme@matroska.org"

[[author]]
initials="D."
surname="Rice"
fullname="Dave Rice"
  [author.address]
  email="dave@dericed.com"

[[author]]
initials="M."
surname="Bunkus"
fullname="Moritz Bunkus"
  [author.address]
  email="moritz@bunkus.org"
%%%

.# Abstract

This document defines the Extensible Binary Meta Language (EBML) format as a generalized file format for any type of data in a hierarchical form. EBML is designed as a binary equivalent to XML and uses a storage-efficient approach to build nested Elements with identifiers, lengths, and values. Similar to how an XML Schema defines the structure and semantics of an XML Document, this document defines how EBML Schemas are created to convey the semantics of an EBML Document.

{mainmatter}
