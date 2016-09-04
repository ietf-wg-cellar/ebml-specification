# EBML Signature

## Status

The EBML Signature Elements are under development and not recommended for use in production. To inquire about, comment upon, or participate in the development of EBML Signatures please contact matroska-devel@lists.matroska.org (with a [public archive](http://lists.matroska.org/pipermail/matroska-devel/)).

## Introduction

The EBML Signature Elements defines a syntax for the storage of digital signatures within an EBML document. The implementation is inspired by the XML Signature defined by the W3C.

This document is dependent on the EBML specification for the structure of EBML Elements and definition of data types.

## Signature Elements

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
    Description:    The signature of the data.

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
