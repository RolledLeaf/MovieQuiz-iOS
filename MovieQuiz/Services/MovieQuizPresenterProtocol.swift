import Foundation

protocol MovieQuizPresenterProtocol {
    func didFailToLoadData(with error: Error)
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didAnswer(isYes: Bool)
    func resetQuiz()
    func showAnswerResult(_ isCorrect: Bool)
}
