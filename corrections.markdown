# `<EBMLSchema>` Namespace RFC

The namespace URI for elements of the EBML Schema is a URN as defined by
[@!RFC8141] instead of the deprecated [@!RFC2141].

# All-zero ID's are allowed

Matroska is using the `0x80` element ID so it **MUST**** be allowed in EBML as well.
Here are the changes needed for this:

- The bits of the VINT\_DATA component of the Element ID **MUST NOT** be all `1` values.
All `0` values are now allowed.
- One-octet Element IDs **MUST** be between 0x80 and 0xFE, rather than between 0x81 and 0xFE.
- 0x80, 0x4000, 0x200000 and 0x10000000 are no longer RESERVED ID's.

# DocTypeVersion Typos

In sections 10.2, 15.1 and 15.2 of [@!RFC8794] the word `EBMLDocTypeVersion` is used where `DocTypeVersion`
should have been used.

# Revised XML Schema for EBML Schema

The XML Schema for the EBML Schema had a few issues:

- The embedded EBML Schema had the default value of the `maxOccurs` attribute set to `1` instead of `unbounded`.
- The `unbounded` value was not legal for the `maxOccurs` attribute.

Here is the revised version.

<{{EBMLSchema.xsd}}
