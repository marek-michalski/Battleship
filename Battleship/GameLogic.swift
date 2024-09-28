//
//  CellState.swift
//  Battleship
//
//  Created by Marek Michalski on 28/09/2024.
//


import SwiftUI

// MARK: - Models

enum CellState {
    case empty
    case ship
    case hit
    case miss
}

struct Ship {
    var size: Int
    var positions: [(x: Int, y: Int)]
    var isSunk: Bool {
        positions.allSatisfy { Game.shared.board[$0.x][$0.y] == .hit }
    }
}

class Game: ObservableObject {
    static let shared = Game()
    
    @Published var board: [[CellState]]
    @Published var ships: [Ship]
    @Published var currentPlayer: Player
    @Published var gameOver: Bool = false
    @Published var winner: Player?
    
    private var playerShips: [Ship] = []
    private var computerShips: [Ship] = []
    
    enum Player {
        case player1
        case player2
        case computer
    }
    
    init() {
        board = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        ships = []
        currentPlayer = .player1
        setupShips()
    }
    
    // Setup Ships for both player and computer
    func setupShips() {
        board = Array(repeating: Array(repeating: .empty, count: 8), count: 8)
        ships.removeAll()
        playerShips = placeShips()
        computerShips = placeShips()
    }
    
    // Randomly place ships on the board
    private func placeShips() -> [Ship] {
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
                        board[pos.x][pos.y] = .ship
                    }
                    let newShip = Ship(size: size, positions: positions)
                    placedShips.append(newShip)
                    placed = true
                }
            }
        }
        
        return placedShips
    }
    
    // Function to handle a move made by a player or computer
    func makeMove(at x: Int, y: Int) {
        guard !gameOver, board[x][y] == .empty || board[x][y] == .ship else { return }
        
        if board[x][y] == .ship {
            board[x][y] = .hit
        } else {
            board[x][y] = .miss
        }
        
        checkWinCondition()
        
        if !gameOver {
            switchTurn()
            if currentPlayer == .computer {
                performComputerMove()
            }
        }
    }
    
    // Switch turns between players
    private func switchTurn() {
        currentPlayer = (currentPlayer == .player1) ? .player2 : .player1
    }
    
    // Check if all ships are sunk to determine a winner
    private func checkWinCondition() {
        if playerShips.allSatisfy({ $0.isSunk }) {
            gameOver = true
            winner = .computer
        } else if computerShips.allSatisfy({ $0.isSunk }) {
            gameOver = true
            winner = .player1
        }
    }
    
    // AI Logic for computer moves
    private func performComputerMove() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            var moveMade = false
            while !moveMade {
                let x = Int.random(in: 0..<8)
                let y = Int.random(in: 0..<8)
                
                if self.board[x][y] == .empty || self.board[x][y] == .ship {
                    self.makeMove(at: x, y)
                    moveMade = true
                }
            }
        }
    }
    
    // Function to reset the game
    func resetGame() {
        gameOver = false
        winner = nil
        currentPlayer = .player1
        setupShips()
    }
}