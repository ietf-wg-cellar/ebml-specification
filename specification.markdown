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

As well as defining standard data types, EBML uses a system of Elements
to make up an EBML "document". Elements incorporate an Element ID, a
descriptor for the size of the element, and the binary data itself.
Futher, Elements can be nested or contain Elements of a lower "level".

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

-   Data size, in octets, is also coded with an UTF-8 like system :

        bits, big-endian
        1xxx xxxx                                                                              - value 0 to  2^7-2
        01xx xxxx  xxxx xxxx                                                                   - value 0 to 2^14-2
        001x xxxx  xxxx xxxx  xxxx xxxx                                                        - value 0 to 2^21-2
        0001 xxxx  xxxx xxxx  xxxx xxxx  xxxx xxxx                                             - value 0 to 2^28-2
        0000 1xxx  xxxx xxxx  xxxx xxxx  xxxx xxxx  xxxx xxxx                                  - value 0 to 2^35-2
        0000 01xx  xxxx xxxx  xxxx xxxx  xxxx xxxx  xxxx xxxx  xxxx xxxx                       - value 0 to 2^42-2
        0000 001x  xxxx xxxx  xxxx xxxx  xxxx xxxx  xxxx xxxx  xxxx xxxx  xxxx xxxx            - value 0 to 2^49-2
        0000 0001  xxxx xxxx  xxxx xxxx  xxxx xxxx  xxxx xxxx  xxxx xxxx  xxxx xxxx  xxxx xxxx - value 0 to 2^56-2

    Since modern computers do not easily deal with data coded in sizes
    greater than 64 bits, any larger Element Sizes are left undefined at
    the moment. Currently, the Element Size coding allows for an Element
    to grow to 72000 To, i.e. 7x10\^16 octets or 72000 terabytes, which
    will be sufficient for the time being.

    There is only one reserved word for Element Size encoding, which is
    an Element Size encoded to all 1's. Such a coding indicates that the
    size of the Element is unknown, which is a special case that we
    believe will be useful for live streaming purposes. However, avoid
    using this reserved word unnecessarily, because it makes parsing
    slower and more difficult to implement.

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
    Element Type:   sub-elements
    Description:    Set the EBML characteristics of the data to follow.
                    Each EBML document has to start with this.

Element Name:   EBMLVersion

    Level:          1
    EBML ID:        [42][86]
    Mandatory:      Yes
    Multiple:       No
    Range:          -
    Default:        1
    Element Type:   u-integer
    Description:    The version of EBML parser used to create the file.

Element Name:   EBMLReadVersion

    Level:          1
    EBML ID:        [42][F7]
    Mandatory:      Yes
    Multiple:       No
    Range:          -
    Default:        1
    Element Type:   u-integer
    Description:    The minimum EBML version a parser has to support to
                    read this file.

Element Name:   EBMLMaxIDLength

    Level:          1
    EBML ID:        [42][F2]
    Mandatory:      Yes
    Multiple:       No
    Range:          -
    Default:        4
    Element Type:   u-integer
    Description:    The maximum length of the IDs you'll find in this
                    file (4 or less in Matroska).

Element Name:   EBMLMaxSizeLength

    Level:          1
    EBML ID:        [42][F3]
    Mandatory:      Yes
    Multiple:       No
    Range:          -
    Default:        8
    Element Type:   u-integer
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
    Element Type:   string
    Description:    A string that describes the type of document that
                    follows this EBML header ('matroska' in our case).

Element Name:   DocTypeVersion

    Level:          1
    EBML ID:        [42][87]
    Mandatory:      Yes
    Multiple:       No
    Range:          -
    Default:        1
    Element Type:   u-integer
    Description:    The version of DocType interpreter used to create
                    the file.

Element Name:   DocTypeReadVersion

    Level:          1
    EBML ID:        [42][85]
    Mandatory:      Yes
    Multiple:       No
    Range:          -
    Default:        1
    Element Type:   u-integer
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
    Element Type:   binary
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
    Element Type:   binary
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
    Element Type:   sub-elements
    Description:    Contain signature of some (coming) elements in the
                    stream.

Element Name:   SignatureAlgo

    Level:          2+
    EBML ID:        [7E][8A]
    Mandatory:      No
    Multiple:       No
    Range:          -
    Default:        -
    Element Type:   u-integer
    Description:    Signature algorithm used (1=RSA, 2=elliptic).

Element Name:   SignatureHash

    Level:          2+
    EBML ID:        [7E][9A]
    Mandatory:      No
    Multiple:       No
    Range:          -
    Default:        -
    Element Type:   u-integer
    Description:    Hash algorithm used (1=SHA1-160, 2=MD5).

Element Name:   SignaturePublicKey

    Level:          2+
    EBML ID:        [7E][A5]
    Mandatory:      No
    Multiple:       No
    Range:          -
    Default:        -
    Element Type:   binary
    Description:    The public key to use with the algorithm (in the
                    case of a PKI-based signature).

Element Name:   Signature

    Level:          2+
    EBML ID:        [7E][B5]
    Mandatory:      No
    Multiple:       No
    Range:          -
    Default:        -
    Element Type:   binary
    Description:    The signature of the data (until a new.

Element Name:   SignatureElements

    Level:          2+
    EBML ID:        [7E][5B]
    Mandatory:      No
    Multiple:       No
    Range:          -
    Default:        -
    Element Type:   sub-elements
    Description:    Contains elements that will be used to compute the
                    signature.

Element Name:   SignatureElementList

    Level:          3+
    EBML ID:        [7E][7B]
    Mandatory:      No
    Multiple:       Yes
    Range:          -
    Default:        -
    Element Type:   sub-elements
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
    Element Type:   binary
    Description:    An element ID whose data will be used to compute
                    the signature.
