import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    func hideLoadingIndicator() {
        
    }
    
    func showLoadingIndicator() {
        
    }
    
    var viewController: MovieQuizViewControllerProtocol?
    var currentQuestionIndex = 0
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    var correctAnswers = 0
    private var statisticService: StatisticServiceProtocol = StatisticService()
    var questionFactory: QuestionFactoryProtocol!
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func didLoadDataFromServer() {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.hideLoadingIndicator()
            self?.questionFactory.requestNextQuestion()
        }
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(viewModel)
            self?.viewController?.hideLoadingIndicator()
        }
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        let isCorrect = givenAnswer == currentQuestion.correctAnswer
        self.showAnswerResult(isCorrect)
    }
    
    func resetQuiz() {
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
        self.questionFactory.requestNextQuestion()
    }
    
    func showAnswerResult(_ isCorrect: Bool) {
        guard let currentQuestion = self.currentQuestion else {
            return
        }
        if isCorrect {
                correctAnswers += 1
            viewController?.highlightImageBorder(isCorrectAnswer: true)
              } else {
                  viewController?.highlightImageBorder(isCorrectAnswer: false)
              }
            viewController?.setButtonsEnabled(false) // Отключаем кнопки после ответа
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self = self else { return }
                self.viewController?.setButtonsEnabled(true) // Включаем кнопки для следующего вопроса
                
                if self.currentQuestionIndex == self.questionsAmount - 1 {
                    self.statisticService.store(correctAnswers: self.correctAnswers, totalQuestions: self.questionsAmount, date: Date())
                    
                    let gamesCount = self.statisticService.gamesCount
                    let bestGame = self.statisticService.bestGame
                    let totalAccuracy = String(format: "%.2f", self.statisticService.totalAccuracy)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
                    let formattedDate = dateFormatter.string(from: bestGame.date)
                    
                    let text = """
                Ваш результат: \(self.correctAnswers)/10
                Количесвто отыгранных квизов: \(gamesCount)
                Рекорд: \(bestGame.correctAnswers)/\(bestGame.totalQuestions), \(formattedDate)
                Средняя точность: \(totalAccuracy)%
                """
                    let viewModel = QuizResultsViewModel(
                        title: "Этот раунд окончен!",
                        text: text,
                        buttonText: "Сыграть ещё раз"
                    )
                    self.viewController?.showResult(quiz: viewModel)
                } else {
                    self.currentQuestionIndex += 1
                    self.viewController?.showLoadingIndicator()
                    self.questionFactory.requestNextQuestion()
                }
            }
        }
    }

