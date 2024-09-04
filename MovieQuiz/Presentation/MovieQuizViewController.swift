import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
   
    
    private var alertPresenter: AlertPresenter?
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol!
    private var currentQuestion: QuizQuestion?
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    //Создал экземпляр класса StatisticService
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        // Инициализируем moviesLoader
            let moviesLoader = MoviesLoader()
            
            // Инициализируем questionFactory с правильными параметрами
            questionFactory = QuestionFactory(delegate: self, moviesLoader: moviesLoader)
            
            questionFactory.loadData() // Запрашиваем данные
            alertPresenter = AlertPresenter(viewController: self)
        
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
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        let model = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать ещё раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            // Возможно, стоит повторить загрузку данных
                  self.questionFactory.requestNextQuestion()
              }
              
              alertPresenter?.showAlert(model: model)
        }
        
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
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
    }
    
    //Использование загрузки в главном потоке через асинхронное выполнение
    func didLoadDataFromServer() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.isHidden = true
            self?.questionFactory.requestNextQuestion()
        }
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
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
