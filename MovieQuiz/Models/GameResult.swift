
//  Created by Vitaly Wexler on 21.08.2024.

import Foundation

struct GameResult {
    let correctAnswers: Int
    let totalQuestions: Int
    let date: Date
    
    func betterOrNot(contestant: GameResult) -> Bool {
        correctAnswers > contestant.correctAnswers
    }
}
