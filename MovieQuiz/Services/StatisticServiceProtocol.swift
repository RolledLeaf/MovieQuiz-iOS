
//  Created by Vitaly Wexler on 21.08.2024.

import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(correctAnswers: Int, totalQuestions: Int, date: Date)
}
