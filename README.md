# Minesweper Assembly

## 1.0 Introdução:

Este projeto implementa o jogo Minesweeper em linguagem Assembly MIPS, como cumprimento da grade curricular da cadeira de Arquitetura E Organização De Computadores ministrada pelo professor Ramon Santos Nepomuceno na Universidade Federal do Cariri - UFCA.

## 1.1 Arquivos do relatorio:

Devido a muitas das funções necessarias para o projeto já estarem completas e nos ser atribuido a criação de apenas algumas delas, aqui constará o detalhamento e explicação das funções que eu construi, e alguns detalhes de outras funções/arquivos que achei importante colocar.

## 2.0 Macros:

Ao logo de todo o codigo Assembly serão usados macros pré-montado, estes são *save_context* e *restore_context*, além das labels *SIZE* e *COUNT_BOMB*, todos esses macros e labels podem ser encontrados no arquivo <a href="https://github.com/Henrique-Izidio/minesweper_assembly/blob/main/macros.asm">macros.asm<a/> e possuem as seguintes funções:

- **save_context:** Salva na memoria os valores de todos os registradores tipo S  e tambem do registrador $ra.
- **restore_context:** Recupera da memoria os valores de todos os registradores tipo S e tambem reistrador ra, atribuindo a eles os valores que eles tinham no momento em que o *save_context* foi chamado pela ultima vez.
- **SIZE:** label equivalente ao valor 8 (número de celulas em uma linha/coluna do tabuleiro).
- **BOMB_COUNT:** label equivalente ao valor 10 (Número total de bombas do tabuleiro).

## 3.0 Função Play:

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

### 3.1 Passagem de parametros:
No arquivo os registradores $a0, $a1, $a2 são responsaveis por armazenarem os valores, respectivamente, do endereço de inicio da matriz relativa ao tabuleiro, linha escolhida pelo usuario e coluna escolhida pelo usuario. Valores que são passados para os registradores tipo S de mesmo número, para que sejam usados ao longo do código.

### 3.2 Acesso a endereços e valores da memoria:

O código a seguir efetua o calculo do deslocamento, em bits, com base nos valores de linha e coluna enviado pelo usuario, armazenando o deslocamento total que deve ser efetuado no registrador $t0, logo em seguida somando o deslocamento ao endereço inicial do tabuleiro. Ao final do código, os registradores $s0 e $s3 armazenam, respectivamente, o endereço e valor da celula nas coordenadas enviadas pelo usuario.

```assembly
sll $t1, $s1, 5 
sll $t2, $s2, 2

add $t0, $t1, $t2

add $s0, $s0, $t0

lw $s3, 0($s0)
```

### 3.3 Comparações:

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

## 4.0 Count Adjacent Bombs

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
### 4.1 Passagem de parametros:
No arquivo os registradores $a0, $a1, $a2 são responsaveis por armazenarem os valores, respectivamente, do endereço de inicio da matriz relativa ao tabuleiro, linha escolhida pelo usuario e coluna escolhida pelo usuario. Valores que são passados para os registradores tipo S de mesmo número, para que sejam usados ao longo do código.

### 4.2 LOOPs:
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

### 4.3 Validação da celula:

O techo a seguir verifica se as coordenadas [i, j] representam um endereço valido do tabuleiro, ou seja, seus valores estão entre 0 e 7.

```assembly
blt $t1, $zero, not_add_count
bge $t2, $s3, not_add_count

blt $t3, $zero, not_add_count
bge $t3, $s3, not_add_count
```
OBS.: *not_add_count* desempenha o mesmo papel de *cab_continue_i*.

### 4.4 Verificação de bomba:
O trecho a seguir captura o valor contido no endereço de memoria relativo a celula das coordenas [i, j] usando a mesma logica apresentada na seção **3.2**. A seguir compara seu valor a $t6(-1), caso sejam diferentes, chamará o not_add_count, do contrario a linha de código subsequente aumentará em 1 o valor de $s4, que representa o número de bombas encontradas na area 3x3 que está sendo pesquisada.
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

### 4.5 Retorno:

Uma vez que ambos os LOOPs tenham se encerrado, ou seja a area 3x3 tenha sido completamente percorrida, ele executará as seguintes linhas de código:

```assembly
move $a3, $s4

restore_context

jr $ra
```

O número de bombas encontradas($s4) é movido para $a3 para que possa ser salvo de maneira global no sistema. As demais linhas foram Explicadas nas seções 3.3 e 2.0 respectivamente.

### 5.0 Reveal Adjacent Cells:
A função a seguir é responsavel por percorrer uma area de 3x3 ao redor da celula recebida em seus parametros revelando para o jogador o valor contido na mesma, para tanto, ela autera o valor da celula de um inteiro negativo(celula com valor escondido), para um inteiro positivo/neutro(celula com valor revelado), este inteiro sendo o número de bombas contidas em suas celulas adjacentes. Por fim, caso uma casa revelada tenha 0 bombas em seu entorno, a função irá chamar a si mesma, assim, revelando as celulas adjacentes da nova celula de valor 0.

Sua equivalencia em Assembly MIPS está contida no arquivo <a href="https://github.com/Henrique-Izidio/minesweper_assembly/blob/main/revealNeighboringCells.asm">revealNeighboringCells.asm<a/>.

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

### 5.1 Passagem de parametros:
Tal como já foi demonstrado nas seções 3.1 e 4.1 *revealNeighboringCells* usa os registradores tipo **a** e tipo **s** para receber os valores de linha, coluna, e inicio da matriz.

### 5.2 LOOPs

 A função *revealNeighboringCells* faz uso do mesmo sistema de LOOPs demonstrado na seção 4.2, porem fazendo uso dos registradores $s3, $s4, $s5 e $s6 para os valores de i e j e seus respectivos valores maximos. A partir de agora $s3 e $s4 serão representados por i e j.

### 5.3 Comparação & Validação:
A cada iteração do codigo ele validará as informações de uma celula diferente, usando o mesmo sistema apresentado na seção 4.3 para checar se [i, j] é uma coordenada valida. A seguir, fazendo uso do mesmo sistema de que carregamento de valores da seção 4.4, o salvando em $t4 e então fazendo a comparação com $t5(-2), caso sejam iguais o codigo saltará para a proxima iteração, do contrario irá continuar.

### 5.4 Chamada de funções:

Ao chegar nesta etapa os valores de i e j serão salvos globalmente em $a1 e $a2 e então é chamada a função *countAdjacentBombs*, explicada na seção 4. O retorno de *countAdjacentBombs* é salvo então no registrador $t0 e transferido para o endereço de memoria contido em $s7(endereço relativo as coordenadas [i, j]), por é chamada de maneira recursiva a função *revealNeighboringCells*.

### 5.5 Retorno:
Uma vez finalizada todas as iterações, os valores de $s1 e $s2 são devolvidos aos registradores $a1 e $a2, para então ser executado os comandos de retorno.

```assembly
move $a1, $s1
move $a2, $s2

restore_context
jr $ra
```

## 6.0 Check Victory:
Está função recebe a matriz tabuleiro como parametro e itera sobre todas as suas celulas, contando o número de celulas com valores positivos/neutros, ou seja já reveladas, caso esse número seja igual ou superior ao número total de cululas subtraido do número total de bombas ela retorna 1 declarando a vitoria do jogador, do contrario ela retorna 0 e o jogo continua.

Sua equivalencia está armazenada no arquivo <a href="https://github.com/Henrique-Izidio/minesweper_assembly/blob/main/checkVictory.asm">checkVictory.asm<a>

```c
int checkVictory(int board[][SIZE]) {
    int count = 0;
    // Checks if the player has won
    for (int i = 0; i < SIZE; ++i) {
        for (int j = 0; j < SIZE; ++j) {
            if (board[i][j] >= 0) {
                count++;
            }
        }
    }
    if (count < SIZE * SIZE - BOMB_COUNT)
        return 0;
    return 1; // All valid cells have been revealed
}
```

### 6.1 Passagem de parametros:

Tal qual apresnetado na seção 3.1 está função usa registradores tipo **a** e **s** para passagem dos parametros, porem nesta foram necessarios apenas os registradores $a0 e $s0 para armazenar o endereço inicial da matriz tabuleiro.

### 6.2 LOOPs

 A função *checkVictory* faz uso do mesmo sistema de LOOPs demonstrado na seção 4.2, usando registradores $t1 e $t2 para i e j, respectivamente, e t0 para o limite maximo de ambos.

### 6.3 Comparação:
Fazendo uso do sistema apresentado na seção 4.3 o sistema verifica se cada uma das celulas possui valor inferior a 0, ou seja se ela ainda está escondida, em caso afirmativo ele saltará para a proxima iteração, do contrario será acrecido 1 no valor de $s2.

### 6.4 Checagem de vitoria:

Ao final de todas a iterações, será multiplicado $t1(SIZE) por ele mesmo, conseguindo assim o número de celulas do tabuleiro, logo em seguida será subtraido $t0(BOMB_SIZE) do valor total de celulas. POr fim, caso o valor adquirido seja igual ou inferior ao valor de $s2 será atribuido o valor 1 ao registrador $v0, do contrario será atribuido o valor 0 ao mesmo, idependente do caso, após isso serão executados os comando de retorno.