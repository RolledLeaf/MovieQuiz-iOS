
//  Created by Vitaly Wexler on 18.08.2024.

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
