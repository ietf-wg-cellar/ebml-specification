# EBML specifications

## EBML principle

EBML is short for Extensible Binary Meta Language. EBML specifies a
binary and octet (byte) aligned format inspired by the principle of XML.
EBML itself is a generalized description of the technique of binary
markup. Like XML, it is completely agnostic to any data that it might
contain. The format is made of 2 parts: the semantic and the syntax.
The semantic specifies a number of IDs and their basic type and is not
included in the data file/stream.

Just like XML, the specific "tags" (IDs in EBML parlance) used in an
EBML implementation are arbitrary. However, the semantic of EBML
outlines general data types and ID's.

## Structure

EBML uses a system of Elements to compose an EBML "document". Elements
incorporate three parts: an Element ID, an Element Data Size, and
Element Data. The Element Data, which is described by the Element ID, 
may include either binary data or one or many other Elements.

## Variable Size Integer

The Element ID and Element Data Size are both encoded as a Variable
Size Integer, developed according to a UTF-8 like system. The Variable
Size Integer is composed of a VINT\_WIDTH, VINT\_MARKER, and VINT\_DATA,
in that order. Variable Size Integers shall be referred to as VINT for
shorthand.

### VINT_WIDTH

Each Variable Size Integer begins with a VINT\_WIDTH which consists of
zero or many zero-value bits. The count of consecutive zero-values of 
the VINT\_WIDTH plus one equals the length in octets of the Variable
Size Integer. For example, a Variable Size Integer that starts with a
VINT\_WIDTH which contains zero consecutive zero-value bits is one octet
in length and a Variable Size Integer that starts with one consecutive
zero-value bit is two octets in length. The VINT\_WIDTH may only contain
zero-value bits or be empty.

### VINT_MARKER

The VINT\_MARKER serves as a separator between the VINT\_WIDTH and
VINT_DATA. Each Variable Size Integer MUST contain exactly one
VINT\_MARKER. The VINT\_MARKER MUST be one bit in length and contain a
bit with a value of one. The first bit with a value of one within the
Variable Size Integer is the VINT\_MARKER.

### VINT_DATA

The VINT\_DATA portion of the Variable Size Integer includes all data
that follows (but not including) the VINT\_MARKER until end of the
Variable Size Integer whose length is derived from the VINT\_WIDTH.
The bits required for the VINT\_WIDTH and the VINT\_MARKER combined use
one bit of each octet of Variable Size Integer length. Thus a Variable
Size Integer of 1 octet length supplies 7 bits for VINT\_DATA, a 2 octet
length supplies 14 bits for VINT\_DATA, and a 3 octet length supplies 21
bits for VINT\_DATA. If the number of bits required for VINT\_DATA are
less than the bit size of VINT\_DATA, then VINT\_DATA may be zero-padded
to the left to a size that fits. The VINT\_DATA value MUST be expressed
a big-endian unsigned integer.

### VINT Examples

This table shows examples of Variable Size Integers at widths of 1 to 5
octets. The Representation column depicts a binary expression of
Variable Size Integers where VINT\_WIDTH is depicted by '0', the
VINT\_MARKER as '1', and the VINT\_DATA as 'x'.

Octet Width | Size | Representation
------------|------|--------------------------------------------------
1           | 2^7  | 1xxx xxxx
2           | 2^14 | 01xx xxxx xxxx xxxx
3           | 2^21 | 001x xxxx xxxx xxxx xxxx xxxx
4           | 2^28 | 0001 xxxx xxxx xxxx xxxx xxxx xxxx xxxx
5           | 2^35 | 0000 1xxx xxxx xxxx xxxx xxxx xxxx xxxx xxxx xxxx

Note that data encoded as a Variable Size Integer may be rendered at
octet widths larger than needed to store the data. In this table a
binary value of 0b10 is shown encoded as different Variable Size
Integers with widths from one octet to four octet. All four encoded
examples have identical semantic meaning though the VINT\_WIDTH and the
padding of the VINT\_DATA vary.

Binary Value | Octet Width | As Represented in Variable Size Integer
-------------|-------------|----------------------------------------
10           | 1           | 1000 0010
10           | 2           | 0100 0000 0000 0010
10           | 3           | 0010 0000 0000 0000 0000 0010
10           | 4           | 0001 0000 0000 0000 0000 0000 0000 0010

## Element ID

The Element ID MUST be encoded as a Variable Size Integer. By default,
EBML Element IDs may be encoded in lengths from one octet to four
octets, although Element IDs of greater lengths may be used if the
octet length of the EBML document's longest Element ID is declared in
the EBMLMaxIDLength Element of the EBML Header. The VINT\_DATA component
of the Element ID MUST NOT be set to either all zero values or all one
values. The VINT\_DATA component of the Element ID MUST be encoded at
the shortest valid length. For example, an Element ID with binary
encoding of 1011 1111 is valid, whereas an Element ID with binary
encoding of 0100 0000 0011 1111 stores a semantically equal VINT\_DATA
but is invalid because a shorter VINT encoding is possible. The
following table details this specific example further:

VINT\_WIDTH | VINT\_MARKER | VINT\_DATA     | Element ID Status
-----------:|-------------:|---------------:|------------------
            | 1            |        0111111 | Valid
0           | 1            | 00000000111111 | Invalid

The octet length of an Element ID determines its EBML Class.

EBML Class | Octet Length | Number of Possible Element IDs
:---------:|:------------:|:------------------------------
Class A    | 1            | 2^7  - 2        =         126
Class B    | 2            | 2^14 - 2^7  - 1 =      16,255
Class C    | 3            | 2^21 - 2^14 - 1 =   2,080,767
Class D    | 4            | 2^28 - 2^21 - 1 = 266,388,303

-    Some Notes:

    -   The leading bits of the Class IDs are used to identify the
        length of the ID. The number of leading 0's + 1 is the length of
        the ID in octets. We will refer to the leading bits as the
        Length Descriptor.
    -   Any ID where all x's are composed entirely of 1's is a Reserved
        ID, thus the -1 in the definitions above.
    -   The Reserved IDs (all x set to 1) are the only IDs that may
        change the Length Descriptor.

## Element Data Size

The Element Data Size expresses the length in octets of Element Data.
The Element Data Size itself MUST be encoded as a Variable Size Integer.
By default, EBML Element Data Sizes can be encoded in lengths from one
octet to eight octets, although Element Data Sizes of greater lengths
MAY be used if the octet length of the EBML document's longest Element
Data Size is declared in the EBMLMaxSizeLength Element of the EBML
Header. Unlike the VINT\_DATA of the Element ID, the VINT\_DATA
component of the Element Data Size is NOT REQUIRED to be encoded at the
shortest valid length. For example, an Element Data Size with binary
encoding of 1011 1111 or a binary encoding of 0100 0000 0011 1111 are
both valid Element Data Sizes and both store a semantically equal value.

Although an Element ID with all VINT\_DATA bits set to zero is invalid,
an Element Data Size with all VINT\_DATA bits set to zero is allowed
for EBML Data Types which do not mandate a non-zero length. In
particular the Signed Integer, Unsigned Integer, Float, and Date EBML
Element Data Types have definitions which require a length of at least
one octet and thus in these cases an Element Data Size with all
VINT\_DATA bits set to zero is invalid. EBML Element Data Types such as
String, UTF-8, Master-element, and Binary do not have definitions that
include minimum lengths greater than one octet and thus Elements of
these Data Types may include an Element Data Size with all VINT\_DATA
bits set to zero. This indicates that the Element Data of the Element
is zero octets in length. Such an Element is referred to as an Empty
Element.

An Element Data Size with all VINT\_DATA bits set to one is reserved as
an indicator that the size of the Element is unknown. The only reserved
value for the VINT\_DATA of Element Data Size is all bits set to one.
This rule allows for an Element to be written and read before the size
of the Element is known; however unknown Element Data Size values SHOULD
NOT be used unnecessarily. An Element with an unknown Element Data Size
MUST be a Master-element in that it contains other EBML Elements as
sub-elements. The end of the Master-element is determined by the
beginning of the next element that is not a valid sub-element of the
Master-element.

For Element Data Sizes encoded at octet lengths from one to eight, this
table depicts the range of possible values that can be encoded as an
Element Data Size. An Element Data Size with an octet length of 8 is
able to express a size of 2^56-2 or 72,057,594,037,927,934 octets (or
about 72 petabytes).

Octet Length | Possible Value Range
-------------|---------------------
1            | 0 to  2^7-2
2            | 0 to 2^14-2
3            | 0 to 2^21-2
4            | 0 to 2^28-2
5            | 0 to 2^35-2
6            | 0 to 2^42-2
7            | 0 to 2^49-2
8            | 0 to 2^56-2

If the length of Element Data equals 2^(n*7)-1 then the octet length of
the Element Data Size MUST be at least n+1. This rule prevents an
Element Data Size from being expressed as a reserved value. For example,
an Element with an octet length of 127 MUST NOT be encoded in an Element
Data Size encoding with a one octet length. The following table
clarifies this rule by showing a valid and invalid expression of an
Element Data Size with a VINT\_DATA of 127 (which is equal to
2^(1*7)-1).

VINT\_WIDTH | VINT\_MARKER | VINT\_DATA     | Element Data Size Status
-----------:|-------------:|---------------:|---------------------------
            | 1            |        1111111 | Reserved (meaning Unknown)
0           | 1            | 00000001111111 | Valid (meaning 127 octets)

-   Data
    -   Integers are stored in their standard big-endian form (no
        UTF-like encoding), only the size may differ from their usual
        form (24 or 40 bits for example).
    -   The Signed Integer is just the big-endian representation trimmed
        from some 0x00 and 0xFF where they are not meaningful (sign).
        For example -2 can be coded as 0xFFFFFFFFFFFFFE or 0xFFFE or
        0xFE and 5 can be coded 0x000000000005 or 0x0005 or 0x05.

## EBML Element Types

Each defined EBML Element MUST have a declared Element Type. The Element Type defines a concept for storing data that may be constrained by length, endianness, and purpose.

Element Data Type:   Signed Integer

    Endianness:     Big-endian
    Length:         A Signed Integer Element MUST declare a length that is no
                    greater than 8 octets. An Signed Integer Element with a
                    zero-octet length represents an integer value of zero.
    Definition:     A Signed Integer stores an integer (meaning that it
                    can be written without a fractional component) which
                    may be negative, positive, or zero. Because EBML
                    limits Signed Integers to 8 octets in length a
                    Signed Element may store a number from
                    −9,223,372,036,854,775,808 to
                    +9,223,372,036,854,775,807.

Element Data Type:   Unsigned Integer

    Endianness:     Big-endian
    Length:         A Unsigned Integer Element MUST declare a length that is no
                    greater than 8 octets. An Unsigned Integer Element with a
                    zero-octet length represents an integer value of zero.
    Definition:     An Unsigned Integer stores an integer (meaning that
                    it can be written without a fractional component)
                    which may be positive or zero. Because EBML limits
                    Unsigned Integers to 8 octets in length an unsigned
                    Element may store a number from 0 to
                    18,446,744,073,709,551,615.

Element Data Type:   Float

    Endianness:     Big-endian
    Length:         A Float Element MUST declare of length of either 0 octets
                    (0 bit), 4 octets (32 bit) or 8 octets (64 bit). A Float
                    Element with a zero-octet length represents a numerical
                    value of zero.
    Definition:     A Float Elements stores a floating-point number as
                    defined in IEEE 754.

Element Data Type:   String

    Endianness:     None
    Length:         A String Element may declare any length (included zero)
                    up to the maximum Element Data Size value permitted.
    Definition:     A String Element may either be empty (zero-length)
                    or contain Printable ASCII characters in the range
                    of 0x20 to 0x7E. Octets with all bits set to zero
                    may follow the string value when needed.

Element Data Type:   UTF-8

    Endianness:     None
    Length:         A UTF-8 Element may declare any length (included zero)
                    up to the maximum Element Data Size value permitted.
    Definition:     A UTF-8 Element shall contain only a valid Unicode
                    string as defined in [RFC 2279](http://www.faqs.org/rfcs/rfc2279.html).
                    Octets with all bits set to zero may follow the
                    UTF-8 value when needed.

Element Data Type:   Date

    Endianness:     None
    Length:         A Date Element MUST declare a length of either 0 octets or 8
                    octets. A Date Element with a zero-octet length represents
                    a timestamp of 2001-01-01T00:00:00.000000000 UTC.
    Definition:     The Date Element MUST contain a Signed Integer that
                    expresses a point in time referenced in nanoseconds
                    from the precise beginning of the third millennium
                    of the Gregorian Calendar in Coordinated Universal
                    Time (also known as 2001-01-01T00:00:00.000000000
                    UTC). This provides a possible expression of time
                    from 1708-09-11T00:12:44.854775808 UTC to
                    2293-04-11T11:47:16.854775807 UTC.

Element Data Type:   Master-element

    Endianness:     None
    Length:         A Master-element may declare any length (included zero)
                    up to the maximum Element Data Size value permitted. The
                    Master-element may also use an unknown length. See the
                    section on Element Data Size for rules that apply to
                    elements of unknown length.
    Definition:     The Master-element contains zero, one, or many other
                    elements. Elements contained within a Master-element
                    must be defined for use at levels greater than the
                    level of the Master-element. For instance is a
                    Master-element occurs on level 2 then all contained
                    Elements must be valid at levels 3.

Element Data Type:   Binary

    Endianness:     None
    Length:         A Master-element may declare any length (included zero)
                    up to the maximum Element Data Size value permitted.
    Definition:     Binary data is not interpreted by the parser.

## Elements semantic

### Element Template

Element Name:

    Level:
    EBML ID:    []
    Mandatory:  [Mandatory]
    Multiple:   [Can be found multiple times at the same level]
    Range:
    Default:    [Default value if the element is not found]
    Element Type:
    Description:

### EBML Basics

Element Name:   EBML

    Level:          0
    EBML ID:        [1A][45][DF][A3]
    Mandatory:      Yes
    Multiple:       Yes
    Range:          -
    Default:        -
    Element Type:   Master-element
    Description:    Set the EBML characteristics of the data to follow.
                    Each EBML document has to start with this.

Element Name:   EBMLVersion

    Level:          1
    EBML ID:        [42][86]
    Mandatory:      Yes
    Multiple:       No
    Range:          -
    Default:        1
    Element Type:   Unsigned Integer
    Description:    The version of EBML parser used to create the file.

Element Name:   EBMLReadVersion

    Level:          1
    EBML ID:        [42][F7]
    Mandatory:      Yes
    Multiple:       No
    Range:          -
    Default:        1
    Element Type:   Unsigned Integer
    Description:    The minimum EBML version a parser has to support to
                    read this file.

Element Name:   EBMLMaxIDLength

    Level:          1
    EBML ID:        [42][F2]
    Mandatory:      Yes
    Multiple:       No
    Range:          -
    Default:        4
    Element Type:   Unsigned Integer
    Description:    The maximum length of the IDs you'll find in this
                    file.

Element Name:   EBMLMaxSizeLength

    Level:          1
    EBML ID:        [42][F3]
    Mandatory:      Yes
    Multiple:       No
    Range:          -
    Default:        8
    Element Type:   Unsigned Integer
    Description:    The maximum length of the sizes you'll find in this
                    file. This does not override the element size
                    indicated at the beginning of an element. Elements
                    that have an indicated size which is larger than
                    what is allowed by EBMLMaxSizeLength SHALL be
                    considered invalid.

Element Name:   DocType

    Level:          1
    EBML ID:        [42][82]
    Mandatory:      Yes
    Multiple:       No
    Range:          -
    Default:        -
    Element Type:   String
    Description:    A string that describes the type of document that
                    follows this EBML header.

Element Name:   DocTypeVersion

    Level:          1
    EBML ID:        [42][87]
    Mandatory:      Yes
    Multiple:       No
    Range:          -
    Default:        1
    Element Type:   Unsigned Integer
    Description:    The version of DocType interpreter used to create
                    the file.

Element Name:   DocTypeReadVersion

    Level:          1
    EBML ID:        [42][85]
    Mandatory:      Yes
    Multiple:       No
    Range:          -
    Default:        1
    Element Type:   Unsigned Integer
    Description:    The minimum DocType version an interpreter has to
                    support to read this file.

### Global elements (used everywhere in the format)

Element Name:   CRC-32

    Level:          1+
    EBML ID:        [BF]
    Mandatory:      No
    Multiple:       No
    Range:          -
    Default:        -
    Element Type:   Binary
    Description:    The CRC is computed on all the data from the last
                    CRC element (or start of the upper level element),
                    up to the CRC element, including other previous CRC
                    elements. All level 1 elements SHOULD include a
                    CRC-32.

Element Name:   Void

    Level:          1+
    EBML ID:        [EC]
    Mandatory:      No
    Multiple:       No
    Range:          -
    Default:        -
    Element Type:   Binary
    Description:    Used to void damaged data, to avoid unexpected
                    behaviors when using damaged data. The content is
                    discarded. Also used to reserve space in a
                    sub-element for later use.
