# EBML – Extensible Binary Markup Language

## About

EBML was designed to be a simplified binary extension of XML for the
purpose of storing and manipulating data in a hierarchical form with
variable field lengths.

It uses the same paradigms as XML files, meaning that syntax and
semantics are separated. So a generic EBML library could read any
format based on it. The interpretation of data is up to a specific
application that knows how each elements (equivalent of XML tag) has
to be handled.

Among all the advantages of XML, there are a few limitations compared
to what XML can achieve:

- There is currently no equivalent to a DTD or Schema to define known
  elements for a document. But we plan on adding such a level.
- No entity can be defined, ie an element that would be replaced by
  another content. We don't plan to add something like this so far.
- No external include of other files (like CSS, images, etc). It could
  be easily added as a "proprietary" element (not defined in the basic
  EBML format).

For the rest, you have all advantages like:

- Upward compatibility when the format is updated. Something rare in
  binary formats, unless you have some unused space in the original
  format.
- Unlimited size of binary data.
- Very size efficient: only space required for a data is written
  (unless you specifically require more space for better updating
  later).

There is also one disadvantage commonly said about XML: it's very
verbose. That's why you should have default/assumed values in you
EBML-based format as much as possible. So you just describe what is
really necessary.

EBML was originally created for the
[Matroska project](https://www.matroska.org/). So this is naturally the
first format based on EBML to exist. You are therefore encouraged to
check the specs to know how to design a format based on EBML.

## Contact

All people that are working on EBML are related to Matroska. So you'd
better contact
[the Matroska team](https://www.matroska.org/contact/index.html).
