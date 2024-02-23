# Minesweper Assembly

## Macros:

Ao logo de todo o codigo Assembly serão usados macros pré-montado, estes são *save_context* e *restore_context*, além das labels *SIZE* e *COUNT_BOMB*, todos esses macros e labels podem ser encontrados no arquivo <a href="https://github.com/Henrique-Izidio/minesweper_assembly/blob/main/macros.asm">macros.asm<a/> e possuem as seguintes funções:

- **save_context:** Salva na memoria os valores de todos os registradores tipo S  e tambem do registrador $ra.
- **restore_context:** Recupera da memoria os valores de todos os registradores tipo S e tambem reistrador ra, atribuindo a eles os valores que eles tinham no momento em que o *save_context* foi chamado pela ultima vez.
- **SIZE:** label equivalente ao valor 8 (número de celulas em uma linha/coluna do tabuleiro).
- **BOMB_COUNT:** label equivalente ao valor 10 (Número total de bombas do tabuleiro).

## Função Play:

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

### Passagem de parametros:
No arquivo os registradores $a0, $a1, $a2 são responsaveis por armazenarem os valores, respectivamente, do endereço de inicio da matriz relativa ao tabuleiro, linha escolhida pelo usuario e coluna escolhida pelo usuario. Valores que são passados para os registradores tipo S de mesmo número, para que sejam usados ao longo do código.

### Acesso a endereços e valores da memoria:

O código a seguir efetua o calculo do deslocamento, em bits, com base nos valores de linha e coluna enviado pelo usuario, armazenando o deslocamento total que deve ser efetuado no registrador $t0, logo em seguida somando o deslocamento ao endereço inicial do tabuleiro. Ao final do código, os registradores $s0 e $s3 armazenam, respectivamente, o endereço e valor da celula nas coordenadas enviadas pelo usuario.

```assembly
sll $t1, $s1, 5 
sll $t2, $s2, 2

add $t0, $t1, $t2

add $s0, $s0, $t0

lw $s3, 0($s0)
```

### Comparações:

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

