//
//  GameLogic.swift
//  Battleship
//
//  Created by Marek Michalski on 28/09/2024.
//

import SwiftUI

// MARK: - Models

//enum CellState {
//    case empty
//    case ship(Player)
//    case hit
//    case miss
//}

enum CellState: Equatable {
    case empty
    case ship(Player)
    case hit
    case miss
}

enum Player {
    case player1
    case player2
}

struct Ship {
    var size: Int
    var positions: [(x: Int, y: Int)]
    var owner: Player
    
    var isSunk: Bool {
        positions.allSatisfy { Game.shared.board[$0.x][$0.y] == .hit }
    }
}

class Game: ObservableObject {
    static let shared = Game()
    
    @Published var board: [[CellState]]
    @Published var currentPlayer: Player
    @Published var gameOver: Bool = false
    @Published var winner: Player?
    
    private var player1Ships: [Ship] = []
    private var player2Ships: [Ship] = []
    
    init() {
        board = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        currentPlayer = .player1
        setupShips()
    }
    
    // Setup Ships for both players
    func setupShips() {
        board = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        player1Ships = placeShips(for: .player1)
        player2Ships = placeShips(for: .player2)
    }
    
    // Randomly place ships on the board
    private func placeShips(for player: Player) -> [Ship] {
        let shipSizes = [2, 3, 3, 4, 5]
        var placedShips: [Ship] = []
        
        for size in shipSizes {
            var placed = false
            while !placed {
                let direction = Bool.random() // true for horizontal, false for vertical
                let x = Int.random(in: 0..<(8 - (direction ? size : 0)))
                let y = Int.random(in: 0..<(8 - (direction ? 0 : size)))
                
                let positions = (0..<size).map {
                    (x: x + (direction ? $0 : 0), y: y + (direction ? 0 : $0))
                }
                
                if positions.allSatisfy({ board[$0.x][$0.y] == .empty }) {
                    for pos in positions {
                        board[pos.x][pos.y] = .ship(player)
                    }
                    let newShip = Ship(size: size, positions: positions, owner: player)
                    placedShips.append(newShip)
                    placed = true
                }
            }
        }
        
        return placedShips
    }
    
    // Function to handle a move made by a player
    func makeMove(at x: Int, y: Int) {
        guard !gameOver, board[x][y] == .empty || isShipCell(board[x][y]) else { return }
        
        if isShipCell(board[x][y]) {
            board[x][y] = .hit
        } else {
            board[x][y] = .miss
        }
        
        checkWinCondition() // Check if the current move results in a win
        
        if !gameOver {
            switchTurn() // Switch turn if the game is not over
        }
    }
    
    // Helper to check if a cell contains a ship
    private func isShipCell(_ state: CellState) -> Bool {
        if case .ship = state {
            return true
        }
        return false
    }
    
    // Switch turns between Player 1 and Player 2
    private func switchTurn() {
        currentPlayer = (currentPlayer == .player1) ? .player2 : .player1
    }
    
    // Check if all ships are sunk to determine a winner
    private func checkWinCondition() {
        // Check if all Player 1's ships are sunk
        if player1Ships.allSatisfy({ $0.isSunk }) {
            gameOver = true
            winner = .player2
        }
        // Check if all Player 2's ships are sunk
        else if player2Ships.allSatisfy({ $0.isSunk }) {
            gameOver = true
            winner = .player1
        }
    }
    
    // Function to reset the game
    func resetGame() {
        gameOver = false
        winner = nil
        currentPlayer = .player1
        setupShips() // Reset the board and re-place ships
    }
}
