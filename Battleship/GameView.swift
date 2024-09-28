//
//  GameView.swift
//  Battleship
//
//  Created by Marek Michalski on 28/09/2024.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var game = Game.shared

    var body: some View {
        VStack {
            Text("Battleship Game")
                .font(.largeTitle)
                .padding()

            HStack {
                // Player 1's view
                VStack {
                    Text("Player 1 View")
                        .font(.headline)
                        .padding()
                    GameBoardView(player: .player1) // Show Player 1's board with Player 2's hidden ships
                }

                // Player 2's view
                VStack {
                    Text("Player 2 View")
                        .font(.headline)
                        .padding()
                    GameBoardView(player: .player2) // Show Player 2's board with Player 1's hidden ships
                }
            }

            if game.gameOver {
                Text("\(game.winner == .player1 ? "Player 1 Wins!" : "Player 2 Wins!")")
                    .font(.headline)
                    .padding()

                Button("Reset Game") {
                    game.resetGame()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            } else {
                Text("Current Turn: \(game.currentPlayer == .player1 ? "Player 1" : "Player 2")")
                    .padding()
            }

            Spacer()
        }
    }
}

struct GameBoardView: View {
    @ObservedObject var game = Game.shared
    var player: Player

    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<8, id: \.self) { x in
                HStack(spacing: 2) {
                    ForEach(0..<8, id: \.self) { y in
                        CellView(x: x, y: y, player: player) // Pass the player to determine visibility
                    }
                }
            }
        }
        .padding()
    }
}

struct CellView: View {
    var x: Int
    var y: Int
    var player: Player
    @ObservedObject var game = Game.shared

    var body: some View {
        Rectangle()
            .fill(colorForCell(game.board[x][y], player: player))
            .frame(width: 40, height: 40)
            .onTapGesture {
                if game.currentPlayer == player {
                    game.makeMove(at: x, y: y)
                }
            }
    }

    private func colorForCell(_ state: CellState, player: Player) -> Color {
        switch state {
        case .empty:
            return Color.blue
        case .ship(let owner):
            // Ships are only visible to the owner, not to the opponent
            if owner == player {
                return player == .player1 ? Color.green : Color.orange
            } else {
                // Hide opponent's ships unless they have been hit
                return Color.blue
            }
        case .hit:
            return Color.red
        case .miss:
            return Color.white
        }
    }
}
