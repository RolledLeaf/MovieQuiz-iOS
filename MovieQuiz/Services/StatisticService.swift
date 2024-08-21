
//  Created by Vitaly Wexler on 21.08.2024.


import Foundation

final class StatisticService {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correctAnswers
        case bestGame
        case gamesCount
        case totalQuestions
        case date
        case totalAccuracy
    }
}

extension StatisticService: StatisticServiceProtocol {
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correctAnswers = storage.integer(forKey: Keys.correctAnswers.rawValue)
            let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
            let date = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
            return GameResult(correctAnswers: correctAnswers, totalQuestions: totalQuestions, date: date)
        }
        set {
            storage.set(newValue.correctAnswers, forKey: Keys.correctAnswers.rawValue)
            storage.set(newValue.totalQuestions, forKey: Keys.totalQuestions.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            return storage.double(forKey: Keys.totalAccuracy.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalAccuracy.rawValue)
        }
    }
    
    func store(correctAnswers: Int, totalQuestions: Int, date: Date) {
        gamesCount += 1
        
        let newAccuracy = Double(correctAnswers) / Double(totalQuestions) * 100
        totalAccuracy = ((totalAccuracy * Double(gamesCount - 1)) + newAccuracy) / Double(gamesCount)
        
        
        if correctAnswers > bestGame.correctAnswers {
            bestGame = GameResult(correctAnswers: correctAnswers, totalQuestions: totalQuestions, date: date)
        }
    }
}
