# EBML specifications

## EBML principle

EBML is short for Extensible Binary Meta Language. EBML specifies a
binary and octet (byte) aligned format inspired by the principle of XML.
EBML itself is a generalized description of the technique of binary
markup. Like XML, it is completely agnostic to any data that it might
contain. Therein, the Matroska project is a specific implementation
using the rules of EBML: It seeks to define a subset of the EBML
language in the context of audio and video data (though it obviously
isn't limited to this purpose). The format is made of 2 parts: the
semantic and the syntax. The semantic specifies a number of IDs and
their basic type and is not included in the data file/stream.

Just like XML, the specific "tags" (IDs in EBML parlance) used in an
EBML implementation are arbitrary. However, the semantic of EBML
outlines general data types and ID's.

The known basic types are:

Data Type        | Definition
-----------------|----------------------------------------------------
Signed Integer   | Big-endian, any size from 1 to 8 octets
Unsigned Integer | Big-endian, any size from 1 to 8 octets
Float            | Big-endian, defined for 4 and 8 octets (32, 64 bits)
String           | Printable ASCII (0x20 to 0x7E), zero-padded when
                 | needed
UTF-8            | [Unicode string](http://www.unicode.org/), zero
                 | padded when needed ([RFC 2279](http://www.faqs.org/rfcs/rfc2279.html))
Date             | signed 8 octets integer in nanoseconds with 0
                 | indicating the precise beginning of the
                 | millennium (at 2001-01-01T00:00:00.000000000 UTC)
Master-element   | contains other EBML sub-elements of the next lower
                 | level
Binary           | not interpreted by the parser

## Structure

EBML uses a system of Elements to compose an EBML "document". Elements
incorporate three parts: an Element ID, an Element Data Size, and
Element Data. The Element Data, which is described by the Element ID, 
may include either binary data or one or many other Elements.

Element IDs are outlined as follows, beginning with the ID itself,
followed by the Data Size, and then the non-interpreted Binary itself:

-   Element ID coded with an UTF-8 like system :

        bits, big-endian
        1xxx xxxx                                  - Class A IDs (2^7 -1 possible values) (base 0x8X)
        01xx xxxx  xxxx xxxx                       - Class B IDs (2^14-1 possible values) (base 0x4X 0xXX)
        001x xxxx  xxxx xxxx  xxxx xxxx            - Class C IDs (2^21-1 possible values) (base 0x2X 0xXX 0xXX)
        0001 xxxx  xxxx xxxx  xxxx xxxx  xxxx xxxx - Class D IDs (2^28-1 possible values) (base 0x1X 0xXX 0xXX 0xXX)

    Some Notes:

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
an Element Data Size with all VINT\_DATA bits set to zero is allowed.
This indicates that the Element Data of the Element is zero octets in
length. Such an Element is referred to as an Empty Element.

An Element Data Size with all VINT\_DATA bits set to one is reserved as
an indicator that the size of the Element is unknown. The only reserved
value for the VINT\_DATA of Element Data Size is all bits set to one.
This rule allows for an Element to be written and read before the size
of the Element is known; however unknown Element Data Size values SHOULD
NOT be used unnecessarily. An Element with an unknown Element Data Size
MUST be a Master-element in that it contains other EBML Elements as
sub-elements. The end of the Master-element is determined by the
beginning of the next element that is not a valid sub-element of the
Master-element. The use of Elements of unknown size is dependent on the
definition of the EBML Schema declared in DocType, because an Element of
unknown size can not be parsed without a complete list of all possible
sub-elements.

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
                    file (4 or less in Matroska).

Element Name:   EBMLMaxSizeLength

    Level:          1
    EBML ID:        [42][F3]
    Mandatory:      Yes
    Multiple:       No
    Range:          -
    Default:        8
    Element Type:   Unsigned Integer
    Description:    The maximum length of the sizes you'll find in this
                    file (8 or less in Matroska). This does not
                    override the element size indicated at the
                    beginning of an element. Elements that have an
                    indicated size which is larger than what is allowed
                    by EBMLMaxSizeLength SHALL be considered invalid.

Element Name:   DocType

    Level:          1
    EBML ID:        [42][82]
    Mandatory:      Yes
    Multiple:       No
    Range:          -
    Default:        -
    Element Type:   String
    Description:    A string that describes the type of document that
                    follows this EBML header ('matroska' in our case).

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

### signature

Element Name:   SignatureSlot

    Level:          1+
    EBML ID:        [1B][53][86][67]
    Mandatory:      No
    Multiple:       Yes
    Range:          -
    Default:        -
    Element Type:   Master-element
    Description:    Contain signature of some (coming) elements in the
                    stream.

Element Name:   SignatureAlgo

    Level:          2+
    EBML ID:        [7E][8A]
    Mandatory:      No
    Multiple:       No
    Range:          -
    Default:        -
    Element Type:   Unsigned Integer
    Description:    Signature algorithm used (1=RSA, 2=elliptic).

Element Name:   SignatureHash

    Level:          2+
    EBML ID:        [7E][9A]
    Mandatory:      No
    Multiple:       No
    Range:          -
    Default:        -
    Element Type:   Unsigned Integer
    Description:    Hash algorithm used (1=SHA1-160, 2=MD5).

Element Name:   SignaturePublicKey

    Level:          2+
    EBML ID:        [7E][A5]
    Mandatory:      No
    Multiple:       No
    Range:          -
    Default:        -
    Element Type:   Binary
    Description:    The public key to use with the algorithm (in the
                    case of a PKI-based signature).

Element Name:   Signature

    Level:          2+
    EBML ID:        [7E][B5]
    Mandatory:      No
    Multiple:       No
    Range:          -
    Default:        -
    Element Type:   Binary
    Description:    The signature of the data (until a new.

Element Name:   SignatureElements

    Level:          2+
    EBML ID:        [7E][5B]
    Mandatory:      No
    Multiple:       No
    Range:          -
    Default:        -
    Element Type:   Master-element
    Description:    Contains elements that will be used to compute the
                    signature.

Element Name:   SignatureElementList

    Level:          3+
    EBML ID:        [7E][7B]
    Mandatory:      No
    Multiple:       Yes
    Range:          -
    Default:        -
    Element Type:   Master-element
    Description:    A list consists of a number of consecutive elements
                    that represent one case where data is used in
                    signature. Ex: <i>Cluster|Block|BlockAdditional</i>
                    means that the BlockAdditional of all Blocks in all
                    Clusters is used for encryption.

Element Name:   SignedElement

    Level:          4+
    EBML ID:        [65][32]
    Mandatory:      No
    Multiple:       Yes
    Range:          -
    Default:        -
    Element Type:   Binary
    Description:    An element ID whose data will be used to compute
                    the signature.
