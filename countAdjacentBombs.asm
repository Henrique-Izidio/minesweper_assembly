.include "macros.asm"

.globl countAdjacentBombs

countAdjacentBombs:
# your code here

  save_context
  
  move $s0, $a0 # $s0 -> inicio do tabuleiro
  move $s1, $a1 # $s1 -> row
  move $s2, $a2 # $s2 -> column
  
  addi $t1, $s1, -1 # i = row - 1
  addi $t2, $s1, 1 # i-max = row + 1
  
  li $s3, SIZE # $s3 = 8
  li $s4, 0 # $s7 -> Count = 0
  
  cab_for_i_start:
    bgt $t1, $t2, cab_for_i_end # if( i > i-max) break;
    
    addi $t3, $s2, -1 # j = column - 1
    addi $t4, $s2, 1 # j-max = column + 1
    
    cab_for_j_start:
      bgt $t3, $t4, cab_for_j_end # if( j > j-max) break;
      
      blt $t1, $zero, not_add_count # if (i < 0) contine;
      bge $t2, $s3, not_add_count # if (i > 8) contine;
      
      blt $t3, $zero, not_add_count # if (j < 0) contine;
      bge $t3, $s3, not_add_count # if (j > 8) contine;
  	
      sll $t5, $t1, 5
      sll $t6, $t3, 2
      
      add $t7, $t5, $t6
      
      add $t5, $t7, $s0
      
      lw $t7, 0($t5)
      
      li $t6, -1
      
      bne $t7, $t6, not_add_count
      
      addi $s4, $s4, 1 # count++
      
      not_add_count: 
        addi $t3, $t3, 1 # j++
 
      j cab_for_j_start
        
    cab_for_j_end:
    
    addi $t1, $t1, 1 # i++
    
    j cab_for_i_start
    
  cab_for_i_end:
  
  move $a3, $s4
  
  restore_context
  
  jr $ra
  
