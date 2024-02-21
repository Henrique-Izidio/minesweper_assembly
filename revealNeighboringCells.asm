.include "macros.asm"

.globl revealNeighboringCells

revealNeighboringCells:

  save_context
  
  move $s0, $a0 # Inicio do Tabuleiro
  move $s1, $a1 # Indice da Linha
  move $s2, $a2 # Indice da Coluna
  
  addi $s3, $s1, -1
  addi $s4, $s1, 1
    
  rnc_start_for_i:
  bgt $s3, $s4, rnc_end_for_i
  
    addi $s5, $s2, -1
    addi $s6, $s2, 1
  
    rnc_start_for_j:
    bgt $s5, $s6, rnc_end_for_j
    
    li $t0, SIZE
    
    bltz $s3, rnc_continue_j
    bltz $s5, rnc_continue_j
    
    bge $s3, $t0, rnc_continue_j
    bge $s5, $t0, rnc_continue_j
    
    sll $t1, $s3, 5
    sll $t2, $s5, 2
    
    add $t3, $t1, $t2
    
    add $s7, $s0, $t3
    
    lw $t4, 0($s7)
    
    li $t5, -2
    
    bne $t4, $t5, rnc_continue_j
    
    move $a0, $s0
    move $a1, $s3
    move $a2, $s5
    
    jal countAdjacentBombs
    
    move $t0, $a3
    
    sw $t0, 0($s7)
    
    bnez $t0, rnc_continue_j
    
    move $a0, $s0
    move $a1, $s3
    move $a2, $s5
    
    jal revealNeighboringCells
    
    rnc_continue_j:
      addi $s5, $s5, 1
     
    j rnc_start_for_j
    
    rnc_end_for_j:
  
  rnc_continue_i:
    addi $s3, $s3, 1
    
  j rnc_start_for_i
  
  rnc_end_for_i:
  
  move $a1, $s1
  move $a2, $s2
  
  restore_context
  jr $ra

