import Foundation
import UIKit

final class MovieQuizPresenter {
    var currentQuestionIndex = 0
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func yesButtonTapped() {
        guard let currentQuestion = currentQuestion else {
            return
        }

        let givenAnswer = true
        
        viewController?.showAnswerResult(givenAnswer == currentQuestion.correctAnswer) //
    }
    
    private func noButtonTapped(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = false
        
        viewController?.showAnswerResult(givenAnswer == currentQuestion.correctAnswer)
    }
}


