//
//  GameView.swift
//  Battleship
//
//  Created by Marek Michalski on 28/09/2024.
//

import SwiftUICore
import SwiftUI

struct GameView: View {
    @ObservedObject var game = Game.shared

    var body: some View {
        VStack {
            Text("Battleship Game")
                .font(.largeTitle)
                .padding()

            GameBoardView()

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

    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<8, id: \.self) { x in
                HStack(spacing: 2) {
                    ForEach(0..<8, id: \.self) { y in
                        CellView(x: x, y: y)
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
    @ObservedObject var game = Game.shared

    var body: some View {
        Rectangle()
            .fill(colorForCell(game.board[x][y]))
            .frame(width: 40, height: 40)
            .onTapGesture {
                game.makeMove(at: x, y: y)
            }
    }

    private func colorForCell(_ state: CellState) -> Color {
        switch state {
        case .empty:
            return Color.blue
        case .ship(let player):
            // Show the ship's color only if it belongs to the current player
            // Opponent's ships remain hidden unless hit
            if player == game.currentPlayer {
                return player == .player1 ? Color.green : Color.orange
            } else {
                // Hide the opponent's ships unless they have been hit
                return Color.blue
            }
        case .hit:
            return Color.red
        case .miss:
            return Color.white
        }
    }
}
