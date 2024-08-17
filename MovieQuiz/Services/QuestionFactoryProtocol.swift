
//  Created by Vitaly Wexler on 17.08.2024.

import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion() -> QuizQuestion?
}
