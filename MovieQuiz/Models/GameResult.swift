import Foundation

struct GameResult {
    let correctAnswers: Int
    let totalQuestions: Int
    let date: Date
    
    func betterOrNot(contestant: GameResult) -> Bool {
        correctAnswers > contestant.correctAnswers
    }
}
