import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    var currentQuestionIndex = 0
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var correctAnswers = 0
    //Создал экземпляр класса StatisticService
    private var statisticService: StatisticServiceProtocol = StatisticService()
    var questionFactory: QuestionFactoryProtocol!
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
                
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
                questionFactory?.loadData()
                viewController.showLoadingIndicator()
    }
    
    func showLoadingIndicator() {
            viewController?.showLoadingIndicator()
        }

        func hideLoadingIndicator() {
            viewController?.hideLoadingIndicator()
        }
    
    func didLoadDataFromServer() {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.hideLoadingIndicator()
            self?.viewController?.activityIndicator.isHidden = true
            self?.questionFactory.requestNextQuestion()
        }
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(viewModel)
        }
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func yesButtonTapped() {
        didAnswer(isYes: true)
    }
    
    private func noButtonTapped(_ sender: Any) {
        didAnswer(isYes: false)
    }
    
     func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        self.showAnswerResult(givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func resetQuiz() {
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
        self.questionFactory.requestNextQuestion()
    }
    
    private func showResult(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText) { [weak self] in
                self?.resetQuiz()
            }
        viewController?.alertPresenter?.showAlert(model: alertModel)
    }
    
    func showAnswerResult(_ isCorrect: Bool) {
        guard let currentQuestion = self.currentQuestion else {
           return
       }
       
       if currentQuestion.correctAnswer == isCorrect {
           correctAnswers += 1
           // Красим рамку в зеленый цвет при правильном ответе
           viewController?.imageView.layer.borderColor = UIColor.ypGreen.cgColor
           viewController?.imageView.layer.cornerRadius = 20
           viewController?.imageView.layer.borderWidth = 8
       } else {
           // Красим рамку в красный цвет при неправильном ответе
           viewController?.imageView.layer.borderColor = UIColor.ypRed.cgColor
           viewController?.imageView.layer.cornerRadius = 20
           viewController?.imageView.layer.borderWidth = 8
       }
        viewController?.noButton.isEnabled = false
        viewController?.yesButton.isEnabled = false
       
       // Переход к следующему вопросу после задержки
       DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
           [weak self] in guard let self else {return}
           viewController?.noButton.isEnabled = true
           viewController?.yesButton.isEnabled = true
           // Завершение викторины
           if self.currentQuestionIndex == questionsAmount - 1 {
               self.statisticService.store(correctAnswers: self.correctAnswers, totalQuestions: self.questionsAmount, date: Date())
               // Получаем сохраненные данные
               let gamesCount = self.statisticService.gamesCount
               let bestGame = self.statisticService.bestGame
               let totalAccuracy = String(format: "%.2f", self.statisticService.totalAccuracy)
               // Настройка отображения формата даты и времени
               let dateFormatter = DateFormatter()
               dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
               let formattedDate = dateFormatter.string(from: bestGame.date)
               let text = """
               Ваш результат: \(correctAnswers)/10
               Количесвто отыгранных квизов:\(gamesCount)
               Рекорд: \(bestGame.correctAnswers)/\(bestGame.totalQuestions), \(formattedDate)
               Средняя точность: \(totalAccuracy)%
               """
               let viewModel = QuizResultsViewModel( // 2
                   title: "Этот раунд окончен!",
                   text: text,
                   buttonText: "Сыграть ещё раз")
               self.showResult(quiz: viewModel) // 3
               // Переход к следующему вопросу
           } else {
               self.currentQuestionIndex += 1
               if self.currentQuestionIndex < self.questionsAmount {
                   questionFactory.requestNextQuestion()
               } else {
                   print("Индекс вне предела массива")
               }
           }
       }
   }
}


