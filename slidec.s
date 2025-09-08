######################################################################
##                                                                  ##
##                          PUBLIC DOMAIN                           ##
##                                                                  ##
######################################################################
/* ---------------------------------------------------------------- */
/*                  MIPS VR4300i ASM : Nintendo 64                  */
/*                    SLI Zelda Format Extension                    */
/*             Dictionary Word Lengths: 65,808 (0x10110)            */
/*                                                                  */
/* Dictionaries and Wide Lengths (HalfWords) are stored in the same */
/* partition, complementing the Literals and Extended Lengths that  */
/* occupy a designated partition.                                   */
/*                                                                  */
/* Usage:                                                           */
/*          void slidstart(unsigned char *src, unsigned char *dst); */
/* ---------------------------------------------------------------- */
  .align 4

  .text
  .globl slidstart
  .ent slidstart
  .set reorder
/* ===== START! ===== */
slidstart:  lw    $24,4($4)
            lw    $7,8($4)    ## Offset Partition HalfWords
            lw    $25,12($4)  ## Offset Partition Octets
            move  $6,$0
            addu  $24,$5,$24
            addu  $7,$4,$7
            addu  $25,$4,$25
            addiu $4,$4,16
/* ===== MAIN LOOP ===== */
slidemain3: beq   $6,$0,load_flags
            nop
            bltz  $8,do_literal       ## if MSb set -> literal
            nop
pressdata3: lhu   $10,0($7)           ## token = *dicts++
            addiu $7,$7,2
            srl   $11,$10,12          ## top4 = token >> 12
            andi  $10,$10,0x0FFF      ## offset_field = token & 0x0FFF
            addiu $9,$5,-1
            subu  $9,$9,$10           ## dst - offset_field - 1
            beqz  $11,len_case0       ## case top4 == 0
            addiu $14,$11,-1          ## tmp = top4 - 1
            beqz  $14,len_case1       ## case top4 == 1
            addiu $11,$11,1           ## default len = top4 + 1
pressloop3: lb    $10,0($9)
            sb    $10,0($5)
            addiu $9,$9,1
            addiu $5,$5,1
            addiu $11,$11,-1
            bne   $11,$0,pressloop3
            nop
exitcheck:  sll   $8,$8,1
            addiu $6,$6,-1
            slt   $14,$5,$24          ## safeguard: dst < dest_end ?
            bnez $14,slidemain3
            nop
            jr    $31
            nop
len_case1:  lhu   $11,0($7)
            addiu $7,$7,2
            addiu $11,$11,273
            b     pressloop3
            nop
len_case0:  lbu   $11,0($25)
            addiu $25,$25,1
            addiu $11,$11,17
            b     pressloop3
            nop
do_literal: lb    $10,0($25)
            addiu $25,$25,1
            sb    $10,0($5)
            addiu $5,$5,1
            b     exitcheck
            nop
load_flags: lw    $8,0($4)            ## load next 32-bit control word
            addiu $4,$4,4
            li    $6,32
            b     slidemain3
            nop
  .end slidstart
