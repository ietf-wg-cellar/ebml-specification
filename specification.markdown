# EBML specifications

## EBML principle

EBML is short for Extensible Binary Meta Language. EBML specifies a binary and octet (byte) aligned format inspired by the principle of XML. EBML itself is a generalized description of the technique of binary markup. Like XML, it is completely agnostic to any data that it might contain. The format is made of 2 parts: the semantic and the syntax. The semantic specifies a number of IDs and their basic type and is not included in the data file/stream.

Just like XML, the specific "tags" (IDs in EBML parlance) used in an EBML implementation are arbitrary. However, the semantic of EBML outlines general data types and ID's.

## Structure

EBML uses a system of Elements to compose an EBML "Document". Elements incorporate three parts: an Element ID, an Element Data Size, and Element Data. The Element Data, which is described by the Element ID, may include either binary data or one or many other Elements.

## Variable Size Integer

The Element ID and Element Data Size are both encoded as a Variable Size Integer, developed according to a UTF-8 like system. The Variable Size Integer is composed of a VINT\_WIDTH, VINT\_MARKER, and VINT\_DATA, in that order. Variable Size Integers shall be referred to as VINT for shorthand.

### VINT_WIDTH

Each Variable Size Integer begins with a VINT\_WIDTH which consists of zero or many zero-value bits. The count of consecutive zero-values of the VINT\_WIDTH plus one equals the length in octets of the VariableSize Integer. For example, a Variable Size Integer that starts with a VINT\_WIDTH which contains zero consecutive zero-value bits is one octet in length and a Variable Size Integer that starts with one consecutive zero-value bit is two octets in length. The VINT\_WIDTH MUST only contain zero-value bits or be empty.

### VINT_MARKER

The VINT\_MARKER serves as a separator between the VINT\_WIDTH and VINT_DATA. Each Variable Size Integer MUST contain exactly one VINT\_MARKER. The VINT\_MARKER MUST be one bit in length and contain a bit with a value of one. The first bit with a value of one within the Variable Size Integer is the VINT\_MARKER.

### VINT_DATA

The VINT\_DATA portion of the Variable Size Integer includes all data that follows (but not including) the VINT\_MARKER until end of the Variable Size Integer whose length is derived from the VINT\_WIDTH. The bits required for the VINT\_WIDTH and the VINT\_MARKER combined use one bit of each octet of Variable Size Integer length. Thus a Variable Size Integer of 1 octet length supplies 7 bits for VINT\_DATA, a 2 octet length supplies 14 bits for VINT\_DATA, and a 3 octet length supplies 21 bits for VINT\_DATA. If the number of bits required for VINT\_DATA are less than the bit size of VINT\_DATA, then VINT\_DATA may be zero-padded to the left to a size that fits. The VINT\_DATA value MUST be expressed a big-endian unsigned integer.

### VINT Examples

This table shows examples of Variable Size Integers at widths of 1 to 5 octets. The Representation column depicts a binary expression of Variable Size Integers where VINT\_WIDTH is depicted by '0', the VINT\_MARKER as '1', and the VINT\_DATA as 'x'.

Octet Width | Size | Representation
------------|------|--------------------------------------------------
1           | 2^7  | 1xxx xxxx
2           | 2^14 | 01xx xxxx xxxx xxxx
3           | 2^21 | 001x xxxx xxxx xxxx xxxx xxxx
4           | 2^28 | 0001 xxxx xxxx xxxx xxxx xxxx xxxx xxxx
5           | 2^35 | 0000 1xxx xxxx xxxx xxxx xxxx xxxx xxxx xxxx xxxx

Note that data encoded as a Variable Size Integer may be rendered at octet widths larger than needed to store the data. In this table a binary value of 0b10 is shown encoded as different Variable Size Integers with widths from one octet to four octet. All four encoded examples have identical semantic meaning though the VINT\_WIDTH and the padding of the VINT\_DATA vary.

Binary Value | Octet Width | As Represented in Variable Size Integer
-------------|-------------|----------------------------------------
10           | 1           | 1000 0010
10           | 2           | 0100 0000 0000 0010
10           | 3           | 0010 0000 0000 0000 0000 0010
10           | 4           | 0001 0000 0000 0000 0000 0000 0000 0010

## Element ID

The Element ID MUST be encoded as a Variable Size Integer. By default, EBML Element IDs may be encoded in lengths from one octet to four octets, although Element IDs of greater lengths may be used if the octet length of the EBML Document's longest Element ID is declared in the EBMLMaxIDLength Element of the EBML Header. The VINT\_DATA component of the Element ID MUST NOT be set to either all zero values or all one values. The VINT\_DATA component of the Element ID MUST be encoded at the shortest valid length. For example, an Element ID with binary encoding of 1011 1111 is valid, whereas an Element ID with binary encoding of 0100 0000 0011 1111 stores a semantically equal VINT\_DATA but is invalid because a shorter VINT encoding is possible. The following table details this specific example further:

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

## Element Data Size

The Element Data Size expresses the length in octets of Element Data. The Element Data Size itself MUST be encoded as a Variable Size Integer. By default, EBML Element Data Sizes can be encoded in lengths from one octet to eight octets, although Element Data Sizes of greater lengths MAY be used if the octet length of the EBML Document's longest Element Data Size is declared in the EBMLMaxSizeLength Element of the EBML Header. Unlike the VINT\_DATA of the Element ID, the VINT\_DATA component of the Element Data Size is NOT REQUIRED to be encoded at the shortest valid length. For example, an Element Data Size with binary encoding of 1011 1111 or a binary encoding of 0100 0000 0011 1111 are both valid Element Data Sizes and both store a semantically equal value.

Although an Element ID with all VINT\_DATA bits set to zero is invalid, an Element Data Size with all VINT\_DATA bits set to zero is allowed for EBML Data Types which do not mandate a non-zero length. An Element Data Size with all VINT\_DATA bits set to zero indicates that the Element Data of the Element is zero octets in length. Such an Element is referred to as an Empty Element. If an Empty Element has a `default` value declared then that default value MUST be interpreted as the value of the Empty Element. If an Empty Element has no `default` value declared then the semantic meaning of Empty Element is defined as part of the definition of the EBML Element Types.

An Element Data Size with all VINT\_DATA bits set to one is reserved as an indicator that the size of the Element is unknown. The only reserved value for the VINT\_DATA of Element Data Size is all bits set to one. This rule allows for an Element to be written and read before the size of the Element is known; however unknown Element Data Size values SHOULD NOT be used unnecessarily. An Element with an unknown Element Data Size MUST be a Master-element in that it contains other EBML Elements as sub-elements. The end of the Master-element is determined by the beginning of the next element that is not a valid sub-element of the Master-element.

For Element Data Sizes encoded at octet lengths from one to eight, this table depicts the range of possible values that can be encoded as an Element Data Size. An Element Data Size with an octet length of 8 is able to express a size of 2^56-2 or 72,057,594,037,927,934 octets (or about 72 petabytes).

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

If the length of Element Data equals 2^(n*7)-1 then the octet length of the Element Data Size MUST be at least n+1. This rule prevents an Element Data Size from being expressed as a reserved value. For example, an Element with an octet length of 127 MUST NOT be encoded in an Element Data Size encoding with a one octet length. The following table clarifies this rule by showing a valid and invalid expression of an Element Data Size with a VINT\_DATA of 127 (which is equal to 2^(1*7)-1).

VINT\_WIDTH | VINT\_MARKER | VINT\_DATA     | Element Data Size Status
-----------:|-------------:|---------------:|---------------------------
            | 1            |        1111111 | Reserved (meaning Unknown)
0           | 1            | 00000001111111 | Valid (meaning 127 octets)

-   Data
    -   Integers are stored in their standard big-endian form (no UTF-like encoding), only the size may differ from their usual form (24 or 40 bits for example).
    -   The Signed Integer is just the big-endian representation trimmed from some 0x00 and 0xFF where they are not meaningful (sign). For example -2 can be coded as 0xFFFFFFFFFFFFFE or 0xFFFE or 0xFE and 5 can be coded 0x000000000005 or 0x0005 or 0x05.

## EBML Element Types

Each defined EBML Element MUST have a declared Element Type. The Element Type defines a concept for storing data that may be constrained by length, endianness, and purpose.

Element Data Type:   Signed Integer

    Endianness:     Big-endian
    Length:         A Signed Integer Element MUST declare a length that is no greater than 8 octets. An Signed Integer Element with a zero-octet length represents an integer value of zero.
    Definition:     A Signed Integer stores an integer (meaning that it can be written without a fractional component) which may be negative, positive, or zero. Because EBML limits Signed Integers to 8 octets in length a Signed Element may store a number from −9,223,372,036,854,775,808 to +9,223,372,036,854,775,807.

Element Data Type:   Unsigned Integer

    Endianness:     Big-endian
    Length:         A Unsigned Integer Element MUST declare a length that is no greater than 8 octets. An Unsigned Integer Element with a zero-octet length represents an integer value of zero.
    Definition:     An Unsigned Integer stores an integer (meaning that it can be written without a fractional component) which may be positive or zero. Because EBML limits Unsigned Integers to 8 octets in length an unsigned Element may store a number from 0 to 18,446,744,073,709,551,615.

Element Data Type:   Float

    Endianness:     Big-endian
    Length:         A Float Element MUST declare of length of either 0 octets (0 bit), 4 octets (32 bit) or 8 octets (64 bit). A Float Element with a zero-octet length represents a numerical value of zero.
    Definition:     A Float Elements stores a floating-point number as defined in IEEE 754.

Element Data Type:   String

    Endianness:     None
    Length:         A String Element may declare any length (included zero) up to the maximum Element Data Size value permitted.
    Definition:     A String Element may either be empty (zero-length) or contain Printable ASCII characters in the range of 0x20 to 0x7E. Octets with all bits set to zero may follow the string value when needed.

Element Data Type:   UTF-8

    Endianness:     None
    Length:         A UTF-8 Element may declare any length (included zero) up to the maximum Element Data Size value permitted.
    Definition:     A UTF-8 Element shall contain only a valid Unicode string as defined in [RFC 2279](http://www.faqs.org/rfcs/rfc2279.html). Octets with all bits set to zero may follow the UTF-8 value when needed.

Element Data Type:   Date

    Endianness:     None
    Length:         A Date Element MUST declare a length of either 0 octets or 8 octets. A Date Element with a zero-octet length represents a timestamp of 2001-01-01T00:00:00.000000000 UTC.
    Definition:     The Date Element MUST contain a Signed Integer that expresses a point in time referenced in nanoseconds from the precise beginning of the third millennium of the Gregorian Calendar in Coordinated Universal Time (also known as 2001-01-01T00:00:00.000000000 UTC). This provides a possible expression of time from 1708-09-11T00:12:44.854775808 UTC to 2293-04-11T11:47:16.854775807 UTC.

Element Data Type:   Master-element

    Endianness:     None
    Length:         A Master-element may declare any length (included zero) up to the maximum Element Data Size value permitted. The Master-element may also use an unknown length. See the section on Element Data Size for rules that apply to elements of unknown length.
    Definition:     The Master-element contains zero, one, or many other elements. Elements contained within a Master-element must be defined for use at levels greater than the level of the Master-element. For instance is a Master-element occurs on level 2 then all contained Elements must be valid at levels 3.

Element Data Type:   Binary

    Endianness:     None
    Length:         A binary element may declare any length (including zero) up to the maximum Element Data Size value permitted.
    Definition:     The contents of a Binary element should not be interpreted by the EBML parser.

## EBML Document

An EBML Document is comprised of only two components, an EBML Header and an EBML Body. An EBML Document MUST start with an EBML Header which declares significant characteristics of the entire EBML Body. An EBML Document MAY only consist of EBML Elements and MUST NOT contain any data that is not part of an EBML Element. The initial EBML Element of an EBML Document and the Elements that follow it are considered Level 0 Elements. If an EBML Master-element is considered to be at level N and it contains one or many other EBML Elements then the contained Elements shall be considered at Level N+1. Thus a Level 2 Element would have to be contained by a Master-element (at Level 1) that is contained by one more Master-element (at Level 0).

### EBML Header

The EBML Header is a declaration that provides processing instructions and identification of the EBML Body. The EBML Header may be considered as analogous to an XML Declaration. A valid EBML Document must start with a valid EBML Header.

The EBML Header documents the EBML Schema (also known as the EBML DocType) that may be used to semantically interpret the structure and meaning of the EBML Document. Additionally the EBML Header documents the versions of both EBML and the EBML Schema that were used to write the EBML Document and the versions required to read the EBML Document.

The EBML Header consists of a single Master-element with an Element ID of 'EBML'. The EBML Header MUST ONLY contain EBML Elements that are defined as part of the EBML Specification.

All EBML Elements within the EBML Header MUST NOT utilize any Element ID with a length greater than 4 octets. All EBML Elements within the EBML Header MUST NOT utilize any Element Data Size with a length greater than 4 octets.

### EBML Body

All data of an EBML Document following the EBML Header may be considered the EBML Body. The end of the EBML Body, as well as the end of the EBML Document that contains the EBML Body, is considered as whichever comes first: the beginning of a new level 0 EBML Header or the end of the file. The EBML Body MAY only consist of EBML Elements and MUST NOT contain any data that is not part of an EBML Element. Although the EBML specification itself defines precisely what EBML Elements are to be used within the EBML Header, the EBML specification does not name or define what EBML Elements are to be used within the EBML Body. The definition of what EBML Elements are to be used within the EBML Body is defined by an EBML Schema.

## EBML Stream

An EBML Stream is a file that consists of one or many EBML Documents that are concatenated together. An occurrence of a Level 0 EBML Header marks the beginning of an EBML Document.

## Elements semantic

### EBML Schema

An EBML Schema is an XML Document that defines the properties, arrangement, and usage of EBML Elements that compose a specific EBML Document Type. The relationship of an EBML Schema to an EBML Document may be considered analogous to the relationship of an [XML Schema](http://www.w3.org/XML/Schema#dev) to an [XML Document](http://www.w3.org/TR/xml/). An EBML Schema MUST be clearly associated with one or many EBML Document Types. An EBML Schema must be expressed as well-formed XML. An EBML Document Type is identified by a unique string stored within the EBML Header element called DocType; for example `matroska` or `webm`.

As an XML Document the EBML Schema MUST use `<table>` as the top level element. The `<table>` element may contain `<element>` sub-elements. Each `<element>` node defines one EBML Element through the use of several attributes. Each attribute of the `<element>` node of the EBML Schema is defined here along with a note to say if the attribute is mandatory or not. EBML Schemas many contain additional attributes to extend the semantics but MUST not conflict is the definitions of the `<element>` attributes defined here.

Within the EBML Schema each EBML Element is defined to occur at a specific level. For any specificied EBML Element that is not at level 0, the Parent EBML Element refers to the EBML Master-element that that EBML Element is contained within. For any specifiied EBML Master-element the Child EBML Element refers to the EBML Elements that may be immediately contained within that Master-element. For any EBML Element that is not defined at level 0, the Parent EBML Element may be identified by the preceding `<element>` node which has a lower value as the defined `level` attribute. The only exception for this rule are Global EBML Elements which may occur within any Parent EBML Element within the restriction of the Global EBML Element's range declaration.

#### EBML Schema Element Attributes

Within an EBML Schema the `<element>` uses the following attributes to define an EBML Element.

| attribute name | required | definition |
|----------------|----------|------------|
| name           | Yes      | The official human-readable name of the EBML Element. The value of the name MUST be in the form of an NCName as defined by the [XML Schema specification](http://www.w3.org/TR/1999/REC-xml-names-19990114/#ns-decl). |
| level          | Yes      | The level notes at what hierarchical depth the EBML Element may occur within an EBML Document. The initial EBML Element of an EBML Document is at level 0 and the Elements that it may contain are at level 1. The level MUST be expressed as an integer; however, the integer may be followed by a '+' symbol to indicate that the EBML Element is valid at any higher level.  |
| global         | No       | A boolean to express if an EBML Element MUST occur at its defined level or may occur within any Parent EBML Element. If the `global` attribute is not expressed for that Element then that element is to be considered not global. |
| id             | Yes      | The Element ID expressed in hexadecimal notation prefixed by a '0x'. |
| mandatory      | No       | A boolean to express if the EBML Element MUST occur if the Parent EBML Element is used. If the mandatory attribute is not expressed for that Element then that element is to be considered not mandatory. |
| multiple       | No       | A boolean to express if the EBML Element may occur within its Parent EBML Element more than once. If the multiple attribute is false or the multiple attribute is not used to define the Element then that EBML Element MUST not occur more than once with that Element's Parent EBML Element. |
| range          | No       | For Elements which are of numerical types (Unsigned Integer, Signed Integer, Float, and Date) a numerical range may be specified. If specified that the value of the EBML Element MUST be within the defined range inclusively. See the [section of Expressions of range](#expression-of-range) for rules applied to expression of range values. |
| default        | No       | A default value may be provided. If an Element is mandatory but not written within its Parent EBML Element, then the parser of the EBML Document MUST insert the defined default value of the Element. EBML Elements that are Master-elements MUST NOT declare a default value. |
| type           | Yes      | As defined within the [section on EBML Element Types](#ebml-element-types), the type MUST be set to one of the following values: 'integer' (signed integer), 'uinteger' (unsigned integer), 'float', 'string', 'date', 'utf-8', 'master', or 'binary'. |

The value of the `<element>` shall contain a description that of the meaning and use of the EBML Element.

#### Expression of range

The `range` attribute MUST only be used with EBML Elements that are either `signed integer` or `unsigned integer`. The `range` attribute does not support date or float EBML Elements. The `range` expression may contain whitespace for readability but whitespace within a `range` expression MUST NOT convey meaning. The expression of the `range` MUST adhere to one of the following forms:

    - `x-y` where x and y are integers and `y` must be greater than `x`, meaning that the value must be greater than or equal to `x` and less than or equal to `y`.
    - `>x` where `x` is an integer, meaning that the value MUST be greater than `x`.
    - `x` where `x` is an integer, meaning that the value MUST be equal `x`.

The `range` may use the prefix `not ` to indicate that the expressed range is negated.

#### Note on the Use of default attributes to define Mandatory EBML Elements

If a Mandatory EBML Element has a default value declared by an EBML Schema and the EBML Element's value is equal to the declared default value then that Element is not required to be present within the EBML Document if its Parent EBML Element is present. In this case, the default value of the Mandatory EBML Element may be assumed although the EBML Element is not present within its Parent EBML Element. Also in this case the parser of the EBML Document MUST insert the defined default value of the Element.

If a Mandatory EBML Element has no default value declared by an EBML Schema and its Parent EBML Element is present than the EBML Element must be present as well. If a Mandatory EBML Element has a default value declared by an EBML Schema and its Parent EBML Element is present and the EBML Element's value is NOT equal to the declared default value then the EBML Element MUST be used.

This table clarifies if a Mandatory EBML Element MUST be written, according to if the default value is declared, if the value of the EBML Element is equal to the declared default value, and if the Parent EBML Element is used.

| Is the default value declared? | Is the value equal to default? | Is the Parent Element used? | Then is storing the EBML Element required? |
|:-----------------:|:-----------------------:|:--------------------:|:------------------------------------------:|
| Yes               | Yes                     | Yes                  | No                                         |
| Yes               | Yes                     | No                   | No                                         |
| Yes               | No                      | Yes                  | Yes                                        |
| Yes               | No                      | No                   | No                                         |
| No                | n/a                     | Yes                  | Yes                                        |
| No                | n/a                     | No                   | No                                         |
| No                | n/a                     | Yes                  | Yes                                        |
| No                | n/a                     | No                   | No                                         |

#### Note on the Use of default attributes to define non-Mandatory EBML Elements

If an EBML Element is not Mandatory, has a defined default value, and is an Empty EBML Element then the EBML Element MUST be interpreted as expressing the default value.

### EBML Header Elements

This specification here contains definitions of all EBML Elements of the EBML Header.

Element Name:   EBML

    Level:          0
    EBML ID:        [1A][45][DF][A3]
    Mandatory:      Yes
    Multiple:       No
    Range:          -
    Default:        -
    Element Type:   Master-element
    Description:    Set the EBML characteristics of the data to follow. Each EBML Document has to start with this.

Element Name:   EBMLVersion

    Level:          1
    EBML ID:        [42][86]
    Mandatory:      Yes
    Multiple:       No
    Range:          -
    Default:        1
    Element Type:   Unsigned Integer
    Description:    The version of EBML parser used to create the EBML Document.

Element Name:   EBMLReadVersion

    Level:          1
    EBML ID:        [42][F7]
    Mandatory:      Yes
    Multiple:       No
    Range:          -
    Default:        1
    Element Type:   Unsigned Integer
    Description:    The minimum EBML version a parser has to support to read this EBML Document.

Element Name:   EBMLMaxIDLength

    Level:          1
    EBML ID:        [42][F2]
    Mandatory:      Yes
    Multiple:       No
    Range:          >3
    Default:        4
    Element Type:   Unsigned Integer
    Description:    The EBMLMaxIDLength is the maximum length in octets of the Element IDs to be found within the EBML Body. An EBMLMaxIDLength value of four is recommended, though larger values are allowed.

Element Name:   EBMLMaxSizeLength

    Level:          1
    EBML ID:        [42][F3]
    Mandatory:      Yes
    Multiple:       No
    Range:          >0
    Default:        8
    Element Type:   Unsigned Integer
    Description:    The EBMLMaxSizeLength is the maximum length in octets of the expression of all Element Data Sizes to be found within the EBML Body. To be clear EBMLMaxSizeLength documents the maximum 'length' of all Element Data Size expressions within the EBML Body and not the maximum 'value' of all Element Data Size expressions within the EBML Body. Elements that have a Element Data Size expression which is larger in octets than what is expressed by EBMLMaxSizeLength SHALL be considered invalid.

Element Name:   DocType

    Level:          1
    EBML ID:        [42][82]
    Mandatory:      Yes
    Multiple:       No
    Range:          -
    Default:        matroska
    Element Type:   String
    Description:    A string that describes and identifies the content of the EBML Body that follows this EBML Header.

Element Name:   DocTypeVersion

    Level:          1
    EBML ID:        [42][87]
    Mandatory:      Yes
    Multiple:       No
    Range:          -
    Default:        1
    Element Type:   Unsigned Integer
    Description:    The version of DocType interpreter used to create the EBML Document.

Element Name:   DocTypeReadVersion

    Level:          1
    EBML ID:        [42][85]
    Mandatory:      Yes
    Multiple:       No
    Range:          -
    Default:        1
    Element Type:   Unsigned Integer
    Description:    The minimum DocType version an interpreter has to support to read this EBML Document.

### Global elements (used everywhere in the format)

Element Name:   CRC-32

    Level:          1+
    Global:         Yes
    EBML ID:        [BF]
    Mandatory:      No
    Multiple:       No
    Range:          -
    Default:        -
    Element Type:   Binary
    Description:    The CRC is computed on all the data from the last CRC element (or start of the upper level element), up to the CRC element, including other previous CRC elements. All level 1 elements SHOULD include a CRC-32.

Element Name:   Void

    Level:          0+
    Global:         Yes
    EBML ID:        [EC]
    Mandatory:      No
    Multiple:       Yes
    Range:          -
    Default:        -
    Element Type:   Binary
    Description:    Used to void damaged data, to avoid unexpected behaviors when using damaged data. The content is discarded. Also used to reserve space in a sub-element for later use.
