# Minesweper Assembly

## Macros:

Ao logo de todo o codigo Assembly serão usados macros pré-montado, estes são *save_context* e *restore_context*, além das labels *SIZE* e *COUNT_BOMB*, todos esses macros e labels podem ser encontrados no arquivo   

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

