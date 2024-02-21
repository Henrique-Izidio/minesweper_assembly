.include "macros.asm"

.globl checkVictory

checkVictory:
# your code here
  save_context
  
  move $s0, $a0

  move $s2, $zero
  
  move $t1, $zero

  li $t2, SIZE
  
  cv_start_for_i:
    bge $t1, $t2, cv_end_for_i
    
    move $t3, $zero
    
    li $t4, SIZE
    
    cv_start_for_j:
    bge $t3, $t4, cv_end_for_j
    
    sll $t5, $t1, 5
    sll $t6, $t2, 2
    
    add $t7, $t5, $t6
    
    add $t5, $s0, $t7
    
    lw $t6, 0($t5)
    
    bltz $t6, cv_continue_for_j
    
    addi $s2, $s2, 1
    
    cv_continue_for_j:
      addi $t3, $t3, 1
      
      j cv_start_for_j
      
    cv_end_for_j:
  
  cv_continue_for_i:
    addi $t1, $t1, 1
    j cv_start_for_i
  cv_end_for_i:
  
  li $t0, BOMB_COUNT
  li $t1, SIZE
  
  mul $t2, $t1, $t1
  
  sub $t3, $t2, $t0
  
  blt $s2, $t3, cv_return_0
  
  li $v0, 1
  
  restore_context
  jr $ra
  
  cv_return_0:
    li $v0, 0
    restore_context
    jr $ra
