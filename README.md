# Minesweper Assembly

## Função Play:
```
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