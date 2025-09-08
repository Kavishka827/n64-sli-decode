######################################################################
##                                                                  ##
##                          PUBLIC DOMAIN                           ##
##                                                                  ##
######################################################################
/* ---------------------------------------------------------------- */
/*                  MIPS VR4300i ASM : Nintendo 64                  */
/*                    SLI Zelda Format Extension                    */
/*             Dictionary Word Lengths: 65,808 (0x10110)            */
/* ---------------------------------------------------------------- */
/*                          SPECIFICATION                           */
/*                                                                  */
/* Endianness   : Big                                               */
/* Header Size  : 16 Octets                                         */
/* Offset 0x00  : [Word] FourCC/Magic Bytes**                       */
/* Offset 0x04  : [Word] Decompressed Length                        */
/* Offset 0x08  : [Word] Offset to Dictionary/Wide-Length HalfWords */
/* Offset 0x0C  : [Word] Offset to Literals/Extended-Length Octets  */
/* Offset 0x10  : Offset to Control-bits Words                      */
/*                                                                  */
/* ** "EAD0" [0x45414430] FourCC recommended.                       */
/* ---------------------------------------------------------------- */

The "SLI Flexible Compression Library" from Nintendo EAD has been in
use for decades, and has received minor alterations/upgrades since its
inception.


This modification to the Library has never been officially put into
use by Nintendo; however, other SDKs from the company have utilized
the concepts of reducing excessive redundancies for streams of data.


######################################################################
##                     brief historical outline                     ##
######################################################################

1994
      "Mario" ["MIO0" (0x4D494F30)] & ["SMSR00" (0x534F53523030)]
               "Mario"                 "Yoshi"

      MAX Dictionary Word Length: 18


1996/7
      "Zelda" ["Yay0" (0x59617930)] & ["Yaz0" (0x59617A30)]
               "Zelda"                 "Zelda2"

      MAX Dictionary Word Length: 273

/!\
"Mario"   - retired with the N64's lifecycle.
"Yoshi"   - unicorn.
"Zelda"   - retired after Luigi's Mansion on the GCN.
"Zelda2"  - remains in active use(?)

######################################################################

Dictionary Structure:

                            +-----nybble
                            |
                            v
               [HalfWord] 0xLOOO (L = Length, O = Offset)

For "Mario", the Length nybble is an absolute threshold supplemented
by a value of 3 to C/W the range 3...18 (0x0...F + 0x3).

"Zelda/2", the nybble functions both as a Length Value and a Flag.
Non-zero values are supplemented with a value of 2 to C/W ranges
3...17 (0x1...F + 0x2), whereas 0 triggers a call to supplement an
Extended Length Value octet with a value of 18 to C/W ranges
18...273 (0x00...FF + 0x12).


Building on the semantics of Zelda, an alteration one step further to
support longer Dictionary Word Lengths is achieved by adding an
extra clause for handling the nybble:

0 - Supplement an Extended Length Value octet with a value of 17
    to C/W ranges 17...272 (0x00...FF + 0x11).
1 - Supplement a Wide Length Value HalfWord with a value of 273
    to C/W ranges 273...65808 (0x0000...FFFF + 0x111)

Non-zero - Supplement by a value of 1 to C/W ranges 3...16
           (0x2...F + 0x1).

######################################################################

Data Structure:

The distinction between Mario/Zelda and Zelda2 is that the former's
method of structuring (partitions) favored facilitated LOAD calls
against the hardware's registers whereas the latter loads data
byte-by-byte.

To capitalize on the partition structure, Wide Length Values are
stored with the other Dictionary HalfWords and the Extended Length
Values remain amidst the Extended Length Value & Literal octets.

Q: "Why use the partition structure?"
A: By using this structure, ROMs compress better when ZIP'd.

######################################################################

                            End of Document
