# Minesweper Assembly

## 1.0 Macros:

Ao logo de todo o codigo Assembly serão usados macros pré-montado, estes são *save_context* e *restore_context*, além das labels *SIZE* e *COUNT_BOMB*, todos esses macros e labels podem ser encontrados no arquivo <a href="https://github.com/Henrique-Izidio/minesweper_assembly/blob/main/macros.asm">macros.asm<a/> e possuem as seguintes funções:

- **save_context:** Salva na memoria os valores de todos os registradores tipo S  e tambem do registrador $ra.
- **restore_context:** Recupera da memoria os valores de todos os registradores tipo S e tambem reistrador ra, atribuindo a eles os valores que eles tinham no momento em que o *save_context* foi chamado pela ultima vez.
- **SIZE:** label equivalente ao valor 8 (número de celulas em uma linha/coluna do tabuleiro).
- **BOMB_COUNT:** label equivalente ao valor 10 (Número total de bombas do tabuleiro).

## 2.0 Função Play:

O código a seguir mostra a função play, ela recebe como parâmetros um tabuleiro bidimensional de inteiros, uma linha e uma coluna. Essa função realiza uma jogada no jogo Campo Minado, verificando se a célula escolhida pelo jogador contém uma bomba, uma célula oculta ou uma célula revelada. Dependendo do caso, a função retorna 0 (fim de jogo), 1 (jogo continua) ou chama outras funções auxiliares (countAdjacentBombs e revealAdjacentCells) para contar e revelar as bombas adjacentes à célula escolhida.

```C
int play(int board[][SIZE], int row, int column) {
    // Performs the move
    if (board[row][column] == -1) {
        return 0; // Player hit a bomb, game over
    }
    if (board[row][column] == -2) {
        int x = countAdjacentBombs(board, row, column); // Marks as revealed
        board[row][column] = x;
        if (!x) revealAdjacentCells(board, row, column); // Reveals adjacent cells
    }
    return 1; // Game continues
}
```

A tradução do código acima para o Assembly MIPS pode ser encontrado no arquivo <a href="https://github.com/Henrique-Izidio/minesweper_assembly/blob/main/play.asm">play.asm<a/>. A seguir encontra-se a explicação do código em Assembly MIPS correlacionado ao código C acima.

### 2.1 Passagem de parametros:
No arquivo os registradores $a0, $a1, $a2 são responsaveis por armazenarem os valores, respectivamente, do endereço de inicio da matriz relativa ao tabuleiro, linha escolhida pelo usuario e coluna escolhida pelo usuario. Valores que são passados para os registradores tipo S de mesmo número, para que sejam usados ao longo do código.

### 2.2 Acesso a endereços e valores da memoria:

O código a seguir efetua o calculo do deslocamento, em bits, com base nos valores de linha e coluna enviado pelo usuario, armazenando o deslocamento total que deve ser efetuado no registrador $t0, logo em seguida somando o deslocamento ao endereço inicial do tabuleiro. Ao final do código, os registradores $s0 e $s3 armazenam, respectivamente, o endereço e valor da celula nas coordenadas enviadas pelo usuario.

```assembly
sll $t1, $s1, 5 
sll $t2, $s2, 2

add $t0, $t1, $t2

add $s0, $s0, $t0

lw $s3, 0($s0)
```

### 2.3 Comparações:

O código a seguir equivale ao conjunto de dois *if* apresentado na função ***play***. Primeiro comparando $s3(valor da celula escolhida) com $t1(-1), caso sejam iguais o codigo irá saltar para a label *play_resturn_0*, explicação adiante. Se o caso anterior não tiver acontecido será feita a comparação de $s3 com $t5(-2) caso sejam diferentes o código saltará para *play_return_1*, do contrário chamará a função *countAdjacentBombs* e a seguir armazenará $a3 (retorno de countAdjacentBombs) no registrador $s4 para uso posterior. Caso $s4 seja diferente de 0 será chamada a label *play_return_1* imediatamente, se não será chamada a função *revealNeighboringCells* para só então ser chamado o *play_return_1*.

```assembly
li $t3, -1
beq $s3, $t3, play_return_0

li $t5, -2
bne $s3, $t5, play_return_1

jal countAdjacentBombs

move $s4, $a3

sw $s4, 0($s0)

bnez $s4, play_return_1

jal revealNeighboringCells

j play_return_1
```

OBS.: As labels *play_return_0* e *play_return_1* atribuem ao registrador $v0 o valor inteiro listado em seus nomes e em seguida realizão os seguintes comandos:

```assembly
restore_context
jr $ra
```
O comando ```jr $ra``` é responsavel por realizar um salto ate o endereço registrado no registrador $ra, valor o qual é atribuido no momento em que o macro *save_context* é chamado.

## 3.0 Count Adjacent Bombs

A função countAdjacentBombs é responsavel por percorrer uma zona 3x3 ao redor da celula escolhida pelo usuario, desde que a area esteja dentro do tabuleiro valido, verificando o número de bombas que existem nessa area e então retornar o número de bombas encontradas. Sua versão em assembly pode ser encontrada no arquivo <a href="https://github.com/Henrique-Izidio/minesweper_assembly/blob/main/countAdjacentBombs.asm">countAdjacentBombs.asm<a/>.

```c
int countAdjacentBombs(int board[][SIZE], int row, int column) {
    // Counts the number of bombs adjacent to a cell
    int count = 0;
    
    for (int i = row - 1; i <= row + 1; ++i) {
        for (int j = column - 1; j <= column + 1; ++j) {
            if (i >= 0 && i < SIZE && j >= 0 && j < SIZE && board[i][j] == -1) {
                count++;
            }
        }
    }
    return count;
}
```
### 3.1 Passagem de parametros:
No arquivo os registradores $a0, $a1, $a2 são responsaveis por armazenarem os valores, respectivamente, do endereço de inicio da matriz relativa ao tabuleiro, linha escolhida pelo usuario e coluna escolhida pelo usuario. Valores que são passados para os registradores tipo S de mesmo número, para que sejam usados ao longo do código.

### 3.2 LOOPs:
O arquivo countAdjacentBombs consta com dois LOOPs responsaveis por percorrer toda a matriz, que representa o tabuleiro de jogo, a seguir é mostrado um exemplo de LOOP:

```assembly
addi $t1, $s1, -1
addi $t2, $s1, 1

cab_for_i_start:
    bgt $t1, $t2, cab_for_i_end

    <<<Código Aqui>>>

    cab_continue_i:
        addi $t1, $t1, 1 # i++
        j cab_for_i_start
cab_for_i_end:
```

O código acima é transcrição do código usado para o LOOP responsavel por percorrer as linhas da matriz. Nele $t1 e $t2 representam os valores de inicio e fim do LOOP, sendo que dentre eles $t1 será o unico a ser modificado ao longo da execução. O comando presente na linha de codigo 5 é a condição de parada do for e indica que caso $t1 seja maior que $t2 o programa ira saltar para a label *cab_for_i_end* encerrando o LOOP. A label *cab_continue_i* é usada em momentos que se deseja interromper a execução da iteração atual e saltar diretamente para a próxima execução, sem necessariamente parar o LOOP completamente. Já os codigos das linhas 10 e 11 são responsaveis por, respectivamente, somar 1 ao valor do registrador $t1 e reiniciar o LOOP.

No arquivo <a href="https://github.com/Henrique-Izidio/minesweper_assembly/blob/main/countAdjacentBombs.asm">countAdjacentBombs.asm<a/> há um segundo LOOP que é responsavel por percorrer as colunas da matriz, porem sua estrutura é igual a está tendo como unica mudança os registradores que representam seu inicio e seu fim, sendo estes $t3 e $t4 respectivamente.

OBS.: A partir de agora irei me referir a $t1 e $t3 como i e j, respectivamente.

### 3.3 Validação da celula:

O techo a seguir verifica se as coordenadas [i, j] representam um endereço valido do tabuleiro, ou seja, seus valores estão entre 0 e 7.

```assembly
blt $t1, $zero, not_add_count
bge $t2, $s3, not_add_count

blt $t3, $zero, not_add_count
bge $t3, $s3, not_add_count
```
OBS.: *not_add_count* desempenha o mesmo papel de *cab_continue_i*.

### 3.4 Verificação de bomba:
O trecho a seguir captura o valor contido no endereço de memoria relativo a celula das coordenas [i, j] usando a mesma logica apresentada na seção **2.2**. A seguir compara seu valor a $t6(-1), caso sejam diferentes, chamará o not_add_count, do contrario a linha de código subsequente aumentará em 1 o valor de $s4, que representa o número de bombas encontradas na area 3x3 que está sendo pesquisada.
```assembly
sll $t5, $t1, 5
sll $t6, $t3, 2

add $t7, $t5, $t6

add $t5, $t7, $s0

lw $t7, 0($t5)

li $t6, -1

bne $t7, $t6, not_add_count

addi $s4, $s4, 1
```

### 3.5 Retorno:

Uma vez que ambos os LOOPs tenham se encerrado, ou seja a area 3x3 tenha sido completamente percorrida, ele executará as seguintes linhas de código:

```assembly
move $a3, $s4

restore_context

jr $ra
```

O número de bombas encontradas($s4) é movido para $a3 para que possa ser salvo de maneira global no sistema. As demais linhas foram Explicadas nas seções 2.3 e 1.0 respectivamente.

### 4.0 Reveal Adjacent Cells:

```c
void revealAdjacentCells(int board[][SIZE], int row, int column) {
    // Reveals the adjacent cells of an empty cell
    for (int i = row - 1; i <= row + 1; ++i) {
        for (int j = column - 1; j <= column + 1; ++j) {
            if (i >= 0 && i < SIZE && j >= 0 && j < SIZE && board[i][j] == -2) {
                int x = countAdjacentBombs(board, i, j); // Marks as revealed
                board[i][j] = x;
                if (!x) revealAdjacentCells(board, i, j); // Continues the revelation recursively
            }
        }
    }
}
```