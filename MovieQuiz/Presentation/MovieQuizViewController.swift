import UIKit

final class MovieQuizViewController: UIViewController {
    
    
    
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let firstStep = questionFactory.requestNextQuestion() {
            currentQuestion = firstStep
            let viewModel = convert(model: firstStep)
            show(viewModel)
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
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in self.resetQuiz()
    
            if let firstQuestion = self.questionFactory.requestNextQuestion() {
                self.currentQuestion = firstQuestion
                let viewModel = self.convert(model: firstQuestion)

                self.show(viewModel)
            }
        }
        alert.addAction(action)
           
           self.present(alert, animated: true, completion: nil)
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
                let text = "Ваш результат: \(correctAnswers)/10" // 1
                        let viewModel = QuizResultsViewModel( // 2
                            title: "Этот раунд окончен!",
                            text: text,
                            buttonText: "Сыграть ещё раз")
                        showResult(quiz: viewModel) // 3
                // Переход к следующему вопросу
            } else {
                self.currentQuestionIndex += 1
                if self.currentQuestionIndex < self.questionsAmount {
                    if let nextQuestion = self.questionFactory.requestNextQuestion() {
                        let viewModel = self.convert(model: nextQuestion)
                        self.show(viewModel)
                }
                } else {
                    
                    print("Индекс вне предела массива")
                }
            }
        }
    }
    private func resetQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        if let firstStep = questionFactory.requestNextQuestion() {
            currentQuestion = firstStep
            let viewModel = convert(model: firstStep)
            show(viewModel)
        }
        
    }
}
