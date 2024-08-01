import UIKit

final class MovieQuizViewController: UIViewController {
    
    struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
    
    
    
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstStep = convert(model: questions[currentQuestionIndex])
        show(firstStep)
    }
    
    @IBAction private func noButtonTapped(_ sender: Any) {
        showAnswerResult(false)
        
    }
    
    
    @IBAction private func yesButtonTapped(_ sender: Any) {
        showAnswerResult(true)
    }
    
    
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
    }
    
   
    private func show(_ step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        // Сбрасываем цвет рамки при показе нового вопроса
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
  
    private func showAnswerResult(_ isCorrect: Bool) {
        let currentQuestion = questions[currentQuestionIndex]
        
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
            self.noButton.isEnabled = true
            self.yesButton.isEnabled = true
            
            // Завершение викторины
            if self.currentQuestionIndex == self.questions.count - 1 {
                let alert = UIAlertController(title: "Этот раунд окончен",
                                              message: "Ваш результат \(self.correctAnswers)/10 ",
                                              preferredStyle: .alert)
                let action = UIAlertAction(title: "Сыграть ещё раз?", style: .default) { _ in
                    self.resetQuiz()
                }
                
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                // Переход к следующему вопросу
            } else {
                self.currentQuestionIndex += 1
                if self.currentQuestionIndex < self.questions.count {
                    let nextQuestion = self.questions[self.currentQuestionIndex]
                    let viewModel = self.convert(model: nextQuestion)
                    self.show(viewModel)
                } else {
                    
                    print("Индекс вне предела массива")
                }
            }
        }
    }
    private func resetQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        let firstStep = convert(model: questions[currentQuestionIndex])
        show(firstStep)
    }
}
