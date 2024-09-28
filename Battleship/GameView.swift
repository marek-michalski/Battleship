struct GameView: View {
    @ObservedObject var game = Game.shared
    
    var body: some View {
        VStack {
            Text("Battleship Game")
                .font(.largeTitle)
                .padding()
            
            GameBoardView()
            
            if game.gameOver {
                Text("\(game.winner == .player1 ? "Player 1 Wins!" : "Computer Wins!")")
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
                Text("Current Turn: \(game.currentPlayer == .player1 ? "Player 1" : "Computer")")
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
                if game.currentPlayer == .player1 {
                    game.makeMove(at: x, y)
                }
            }
    }

    private func colorForCell(_ state: CellState) -> Color {
        switch state {
        case .empty:
            return Color.blue
        case .ship:
            return Color.gray
        case .hit:
            return Color.red
        case .miss:
            return Color.white
        }
    }
}