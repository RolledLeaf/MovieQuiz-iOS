protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(_ step: QuizStepViewModel)
    func showResult(quiz result: QuizResultsViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func setButtonsEnabled(_ isEnabled: Bool)
    func showNetworkError(message: String)
}
