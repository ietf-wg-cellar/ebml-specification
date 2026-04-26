# Introduction

EBML, short for Extensible Binary Meta Language, specifies a binary format
aligned with octets (bytes) and inspired by the principle of XML (a framework for
structuring data). It is defined in [@!RFC8794].

When adding a new EBML Element to an EBML format certain attributes need to be set for that element.
They are defined in the text version of the format specification
and can also be defined in an EBML Schema.

This document adds new attributes to the definition of an EBML Element.
It allows gradually adding new elements that are backward compatible for a given
`EBML DocType` version and distinguish between states of the specification at a given update version or date.

# Notation and Conventions

The key words "**MUST**", "**MUST NOT**",
"**REQUIRED**", "**SHALL**", "**SHALL NOT**",
"**SHOULD**", "**SHOULD NOT**",
"**RECOMMENDED**", "**NOT RECOMMENDED**",
"**MAY**", and "**OPTIONAL**" in this document are to be interpreted as
described in BCP 14 [@!RFC2119] [@!RFC8174]
when, and only when, they appear in all capitals, as shown here.

# New `<EBMLSchema>` Attributes

## update Attribute

A new attribute is added to the list of attributes found in [@?RFC8794, section 11.1.4].

Within an EBML Schema, the XPath of the new `@update` attribute is `/EBMLSchema/@update`.

`update` is a nonnegative integer expressing the update version in which a given element was added to the EBML Schema of an `EBML DocType`.

The syntax of the `update` values is defined using this Augmented Backus-Naur Form (ABNF) [@!RFC5234] notation:

```abnf
update           = 1*DIGIT
```

The `update` attribute is **OPTIONAL** within the <EBMLSchema> Element and the EBML Element text definition.
If the `update` attribute is not present the element is considered to have always
been present in `minver` [@!RFC8794, section 11.1.6.13] version of the format it's defined for.

## added Attribute

A new attribute is added to the list of attributes found in [@?RFC8794, section 11.1.4].

Within an EBML Schema, the XPath of the new `@added` attribute is `/EBMLSchema/@added`.

`added` is a nonnegative integer expressing the date when a given element was added to the EBML Schema of an `EBML DocType`.
The value is in the form "YYYYMMDD" where YYYY represents the year similar to the `date-fullyear` in [@!RFC3339, section 5.6],
"MM" represents the month similar to the `date-month` in [@!RFC3339, section 5.6],
and "DD" represents the month similar to the `date-mday` in [@!RFC3339, section 5.6].

The "-" separator is not included for easier comparison in XSLT.

The syntax of the `added` values is defined using this Augmented Backus-Naur Form (ABNF) [@!RFC5234] notation:

```abnf
date-fullyear   = 4DIGIT
date-month      = 2DIGIT  ; 01-12
date-mday       = 2DIGIT  ; 01-28, 01-29, 01-30, 01-31 based on
                          ; month/year

added           = date-fullyear date-month date-mday
```

The `added` attribute is **OPTIONAL** within the <EBMLSchema> Element and the EBML Element text definition.
If the `added` attribute is not present the element is considered to have always
been present in `minver` [@!RFC8794, section 11.1.6.13] version of the format it's defined for.

# Updated EBML Schema

The following provides the updated XML Schema [@!XML-SCHEMA] of the EBML Schema
found in [@!RFC8794, section 11.1.16].

<{{EBMLSchema.xsd}}

