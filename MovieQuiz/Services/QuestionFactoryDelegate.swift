import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
    extension QuestionFactoryDelegate {
        func hideLoadingIndicator() {}
        func showLoadingIndicator() {}
    }

