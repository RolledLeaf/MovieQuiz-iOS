import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    
    private var alertPresenter: AlertPresenter?
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory.setup(delegate: self) // Устанавливаем делегат
        questionFactory.requestNextQuestion() // Запрашиваем первый вопрос
        
        alertPresenter = AlertPresenter(viewController: self)
        
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(viewModel)
        }
        
    }
    
    
    @IBAction private func noButtonTapped(_ sender: Any) {
        showAnswerResult(false)
        
    }
    
    
    @IBAction private func yesButtonTapped(_ sender: Any) {
        showAnswerResult(true)
    }
    
    
    //Исправил count на questionsAmount
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    
    private func show(_ step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        // Сбрасываем цвет рамки при показе нового вопроса
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func showResult(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText) { [weak self] in
                self?.resetQuiz()
            }
        
        alertPresenter?.showAlert(model: alertModel)
        
    } // конец функции showResults
    
    
    //Исправлено questions[currentQuestionIndex] на currentQuestion
    private func showAnswerResult(_ isCorrect: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        if currentQuestion.correctAnswer == isCorrect {
            correctAnswers += 1
            // Красим рамку в зеленый цвет при правильном ответе
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            imageView.layer.cornerRadius = 20
            imageView.layer.borderWidth = 8
        } else {
            // Красим рамку в красный цвет при неправильном ответе
            imageView.layer.borderColor = UIColor.ypRed.cgColor
            imageView.layer.cornerRadius = 20
            imageView.layer.borderWidth = 8
        }
        
        
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        // Переход к следующему вопросу после задержки
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            [weak self] in guard let self else {return}
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true
            
            // Завершение викторины
            if self.currentQuestionIndex == self.questionsAmount - 1 {
                self.statisticService.store(correctAnswers: self.correctAnswers, totalQuestions: self.questionsAmount, date: Date())
                // Получаем сохраненные данные
                let gamesCount = self.statisticService.gamesCount
                let bestGame = self.statisticService.bestGame
                let totalAccuracy = String(format: "%.2f", self.statisticService.totalAccuracy)
                let text = "Ваш результат: \(correctAnswers)/10 \n Количесвто отыгранных квизов:\(gamesCount) \n Рекорд: \(bestGame.correctAnswers)/\(bestGame.totalQuestions) \n Средняя точность: \(totalAccuracy)%"
                let viewModel = QuizResultsViewModel( // 2
                    title: "Этот раунд окончен!",
                    text: text,
                    buttonText: "Сыграть ещё раз")
                showResult(quiz: viewModel) // 3
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
    private func resetQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory.requestNextQuestion()
        
    }
}
