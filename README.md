# Minesweper Assembly

## Função Play:
---
___
```
.include "macros.asm"

.globl play

play:
# your code here

  save_context
    move $s0, $a0 # Inicio do Tabuleiro
    move $s1, $a1 # Indice da Linha
    move $s2, $a2 # Indice da Coluna
    
  
  # board[row][column]
    sll $t1, $s1, 5 # Armazenar Indice da linha, em Bits
    sll $t2, $s2, 2 # Armazenar Indice da coluna, em Bits
  
    add $t0, $t1, $t2 # Gera deslocamento logico necessario para acessar os indices corretos do tabuleiro
    
    add $s0, $s0, $t0 # Recupera Endere�o completo do indice desejado
  
    lw $s3, 0($s0) # Recuperar valor contido no endere�o encontrado
  
  # if(board[row][column] == -1) return 0
    li $t3, -1
    beq $s3, $t3, play_return_0
   
   # if(board[row][column] == -2)
    li $t5, -2
    bne $s3, $t5, play_return_1 # $a3 = countAdjacentBombs()
    
    jal countAdjacentBombs
    
    move $s4, $a3
    
    sw $s4, 0($s0)
    
    bnez $s4, play_return_1
    
    jal revealNeighboringCells
    
    j play_return_1
    
play_return_0:
  move $v0, $zero
  restore_context
  jr $ra
    
play_return_1:
  li $v0, 1
  restore_context
  jr $ra
  

```