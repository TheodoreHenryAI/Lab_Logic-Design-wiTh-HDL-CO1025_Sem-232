`timescale 1ns / 1ps

module tic_tac_toe (
    input wire clk,         // System clock input
    input wire reset,       // Reset input (active low)
    input wire left,      // Button for left (move cursor left)
    input wire right,     // Button for right (move cursor right)
    input wire confirm,   // Button to confirm selection
    output reg [8:0] leds, // to show if enough led implemented
    output reg lreset,      // LED for reset
    output reg game_over,       // State machine state register
    output reg p1,    // Player 1 == Player X
    output reg p2,   // Player 2 == Player O
    output reg player_turn,                // Current player's turn (X or O)
    output reg [1:0] winner,       // Winner (11 for draw, 01 for X, 10 for O)
    // Additional variables for cursor position
output reg [1:0] p_row,          // Cursor row position (0 to SIZE-1)
output reg [1:0] p_col           // Cursor column position (0 to SIZE-1)
);

// Define states and constants
parameter SIZE = 3;         // Size of the tic tac toe grid (3x3)

parameter X = 1'b0;         // X player state
parameter O = 1'b1;         // O player state


parameter EMPTY = 2'b00;       // Empty cell value
parameter X_MARK = 2'b01;      // X player's mark
parameter O_MARK = 2'b10;      // O player's mark
reg [1:0] board [2:0][2:0];     // Game board (3x3 grid) (0, 1, 2 for naming)

// State machine states
parameter IDLE = 1'b0;         // Idle state (waiting for input)
parameter PLACE = 1'b1;   // Place mark state
reg state;

integer i;
integer j;
// Reset all game variables
always @(posedge clk or negedge reset) begin
    if (~reset) begin
    lreset <= 1;
    leds <= 9'b000000000;
    state <= IDLE;
        player_turn <= X;  // X starts first
        // Initialize board to empty
         for ( i = 0; i <= SIZE - 1; i = i + 1) begin
            for ( j = 0; j <= SIZE - 1; j = j + 1) begin
                board[i][j] <= EMPTY;
            end
        end
        // Set Pointer to (0,0)
        p_row <= 2'b00;
        p_col <= 2'b00;
        // Initialize LEDs to all off
        p1 <= 1'b0;
        p2 <= 1'b0; 
        game_over <= 1'b0;
        winner <= 2'b00;
    end 
    else begin
    lreset <= 0;
    i = 0;
    j = 0;
    end
end

// State machine for controlling the game flow
always @(posedge clk) begin
if (reset && state == IDLE && game_over == 0) begin
    if (left && (p_col > 0)) // move to the left col if at col 2 or 3
        p_col <= p_col - 1;
    else if (right && (p_col < SIZE - 1)) // move to right col if at col 1 or 2
        p_col <= p_col + 1;
    else if (right && (p_col == SIZE - 1)) begin // move to right at col 3
        p_col <= 0;
        if (p_row < SIZE - 1) // move to next row if available
           p_row <= p_row + 1;
           else
           p_row <= 0; // Wrap around to the first row if not
        end
    else if (left && (p_col == 0)) begin // move to left at col 1
        p_col <= SIZE - 1;
           if (p_row != 0) // move to previous row if available
               p_row <= p_row - 1;
           else
               p_row <= SIZE - 1; // Wrap around to the last row if not
        end
        
    else if (confirm) begin // Press select button
         if (board[p_row][p_col] == EMPTY) begin
            if (player_turn == X) begin
               board[p_row][p_col] <= X_MARK;
            $display("Player 1 place mark X at ( %d, %d )", p_row, p_col);
            end
            else begin
               board[p_row][p_col] <= O_MARK;
            $display("Player 2 place mark O at ( %d, %d )", p_row, p_col);
            end
            state <= PLACE;
            end
         end
     end
 end
// Output LEDs based on game board and game status
always @(posedge clk) begin
if (state == PLACE) begin
// Check win conditions after placing mark
            // Check rows
            if (board[p_row][0] == board[p_row][1] &&
                board[p_row][1] == board[p_row][2]) begin
                $display("ROW WIN");
                game_over <= 1;
                // Game over: indicate winner or draw
         if (board[p_row][p_col] == X_MARK && !p1 && !p2) begin
                winner <= 2'b01; // X wins
                p1 <= 1'b1;
                end
            else if (board[p_row][p_col] == O_MARK && !p1 && !p2) begin
                winner <= 2'b10; // O wins
                p2 <= 1'b1;
                end
                    $display("Game state: %d, over? : %d", state, game_over);
                    state <= IDLE;
                end
            // Check columns
            else if (board[0][p_col] == board[1][p_col] &&
                     board[1][p_col] == board[2][p_col]) begin
                $display("COL WIN");
                game_over <= 1;
                // Game over: indicate winner or draw
         if (board[p_row][p_col] == X_MARK && !p1 && !p2) begin
                winner <= 2'b01; // X wins
                p1 <= 1'b1;
                end
            else if (board[p_row][p_col] == O_MARK && !p1 && !p2) begin
                winner <= 2'b10; // O wins
                p2 <= 1'b1;
                end
                    $display("Game state: %d, over? : %d", state, game_over);
                    state <= IDLE;
                end
           
            // Check diagonals
            else if ((p_row == p_col &&
                      board[0][0] == board[1][1] &&
                      board[1][1] == board[2][2]) ||
                     (p_row + p_col == 2 &&
                      board[0][2] == board[1][1] &&
                      board[1][1] == board[2][0])) begin
                $display("DIAGONAL WIN");
                game_over <= 1;
                // Game over: indicate winner or draw
         if (board[p_row][p_col] == X_MARK && !p1 && !p2) begin
                winner <= 2'b01; // X wins
                p1 <= 1'b1;
                end
            else if (board[p_row][p_col] == O_MARK && !p1 && !p2) begin
                winner <= 2'b10; // O wins
                p2 <= 1'b1;
                end
                    $display("Game state: %d, over? : %d", state, game_over);
                    state <= IDLE;
                end
            
            // Check for draw
            else if (board[0][0] != EMPTY && board[0][1] != EMPTY && board[0][2] != EMPTY &&
                 board[1][0] != EMPTY && board[1][1] != EMPTY && board[1][2] != EMPTY &&
                 board[2][0] != EMPTY && board[2][1] != EMPTY && board[2][2] != EMPTY) begin
               game_over <= 1;
               // Game over: indicate winner or draw
         winner <= 2'b11; // draw
                    $display("Game state: %d, over? : %d", state, game_over);
                    state <= IDLE;
               $display("DRAW");
               p1 <= 1'b1;
               p2 <= 1'b1;
            end
    if (game_over == 0) begin  ////
    if (player_turn == X)
                    player_turn <= O;
                else
                    player_turn <= X;
                    state <= IDLE;
                end
                    $display("Game state: %d, over? : %d", state, game_over);
         end
    end
// Output LEDs based on game board and game status
always @(posedge clk) begin
    if (game_over == 1) begin
        // Game over: indicate winner or draw
        case (winner)
            2'b01: leds <= 9'b101_010_101; // LEDs for X wins
            2'b10: leds <= 9'b111_101_111; // LEDs for O wins
            2'b11: leds <= 9'b111_111_111; // LEDs for draw
        endcase
    end
    else begin
        // Game ongoing: update LEDs to show board state
        leds <= 9'b000000000;
        // Highlight current cursor position
        leds[p_row * 3 + p_col] <= 1'b1;
    end
end

endmodule