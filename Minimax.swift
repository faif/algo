import Foundation

enum Piece: String {
    case X = "X"
    case O = "O"
    case E = " "
    var opposite: Piece {
        switch self {
        case .X:
            return .O
        case .O:
            return .X
        case .E:
            return .E
        }
    }
}

// a move is an integer 0-8 indicating a place to put a piece
typealias Move = Int

struct Board {
    let position: [Piece]
    let turn: Piece
    let lastMove: Move

    // by default the board is empty and X goes first
    // lastMove being -1 is a marker of a start position
    init(position: [Piece] = [.E, .E, .E, .E, .E, .E, .E, .E, .E], turn: Piece = .X, lastMove: Int = -1) {
        self.position = position
        self.turn = turn
        self.lastMove = lastMove
    }

    // location can be 0-8, indicating where to move
    // return a new board with the move played
    func move(_ location: Move) -> Board {
        var tempPosition = position
        tempPosition[location] = turn
        return Board(position: tempPosition, turn: turn.opposite, lastMove: location)
    }
    
    // the legal moves in a position are all of the empty squares
    var legalMoves: [Move] {
        return position.indices.filter { position[$0] == .E }
    }
    
    var isWin: Bool {
        return
            position[0] == position[1] && position[0] == position[2] && position[0] != .E || // row 0
            position[3] == position[4] && position[3] == position[5] && position[3] != .E || // row 1
            position[6] == position[7] && position[6] == position[8] && position[6] != .E || // row 2
            position[0] == position[3] && position[0] == position[6] && position[0] != .E || // col 0
            position[1] == position[4] && position[1] == position[7] && position[1] != .E || // col 1
            position[2] == position[5] && position[2] == position[8] && position[2] != .E || // col 2
            position[0] == position[4] && position[0] == position[8] && position[0] != .E || // diag 0
            position[2] == position[4] && position[2] == position[6] && position[2] != .E // diag 1
        
    }
    
    var isDraw: Bool {
        return !isWin && legalMoves.count == 0
    }
}

// Find the best possible outcome for originalPlayer
func minimax(_ board: Board, maximizing: Bool, originalPlayer: Piece) -> Int {
    // Base case — evaluate the position if it is a win or a draw
    if board.isWin && originalPlayer == board.turn.opposite { return 1 } // win
    else if board.isWin && originalPlayer != board.turn.opposite { return -1 } // loss
    else if board.isDraw { return 0 } // draw
    
    // Recursive case — maximize your gains or minimize the opponent's gains
    if maximizing {
        var bestEval = Int.min
        for move in board.legalMoves { // find the move with the highest evaluation
            let result = minimax(board.move(move), maximizing: false, originalPlayer: originalPlayer)
            bestEval = max(result, bestEval)
        }
        return bestEval
    } else { // minimizing
        var worstEval = Int.max
        for move in board.legalMoves {
            let result = minimax(board.move(move), maximizing: true, originalPlayer: originalPlayer)
            worstEval = min(result, worstEval)
        }
        return worstEval
    }
}

// Run minimax on every possible move to find the best one
func findBestMove(_ board: Board) -> Move {
    var bestEval = Int.min
    var bestMove = -1
    for move in board.legalMoves {
        let result = minimax(board.move(move), maximizing: false, originalPlayer: board.turn)
        if result > bestEval {
            bestEval = result
            bestMove = move
        }
    }
    return bestMove
}

// find the best move to win in 2 moves
let toWinHardPosition: [Piece] = [.X, .E, .E,
                                  .E, .E, .O,
                                  .O, .X, .E]
let testBoard: Board = Board(position: toWinHardPosition, turn: .X, lastMove: 6)
let answer = findBestMove(testBoard)
print("Place X to position \(answer) to win")
