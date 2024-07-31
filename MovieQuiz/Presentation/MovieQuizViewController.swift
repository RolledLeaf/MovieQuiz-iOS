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
    
    @IBAction private func noButton(_ sender: Any) {
        showAnswerResult(false)
    }
    
    @IBAction private func yesButton(_ sender: Any) {
        showAnswerResult(true)
    }
    
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
        
        // Показ первого вопроса при загрузке
        let firstStep = convert(model: questions[currentQuestionIndex])
        show(firstStep)
    }
    
    // Конвертация QuizQuestion в QuizStepViewModel
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
    }
    
    // Показ QuizStepViewModel на UI
    private func show(_ step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        // Сбрасываем цвет рамки при показе нового вопроса
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    // Обработка ответа пользователя
    private func showAnswerResult(_ isCorrect: Bool) {
        let currentQuestion = questions[currentQuestionIndex]
        
        if currentQuestion.correctAnswer == isCorrect {
            correctAnswers += 1
            // Красим рамку в зеленый цвет при правильном ответе
            imageView.layer.borderColor = UIColor.green.cgColor
            imageView.layer.cornerRadius = 6 // радиус скругления углов рамки
            imageView.layer.borderWidth = 5.0
        } else {
            // Красим рамку в красный цвет при неправильном ответе
            imageView.layer.borderColor = UIColor.red.cgColor
            imageView.layer.cornerRadius = 6 // радиус скругления углов рамки
            imageView.layer.borderWidth = 5.0
        }
        
        
        
        // Переход к следующему вопросу после задержки
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            self.currentQuestionIndex += 1
            
            if self.currentQuestionIndex < self.questions.count {
                let nextStep = self.convert(model: self.questions[self.currentQuestionIndex])
                self.show(nextStep)
            } else {
                
                // Завершение викторины
                let alert = UIAlertController(title: "Этот раунд окончен", // заголовок всплывающего окна
                                              message: "Ваш результат \(self.correctAnswers)/10 ", // текст во всплывающем окне
                                              preferredStyle: .alert)
                let action = UIAlertAction(title: "Сыграть ещё раз?", style: .default) { _ in
                    self.resetQuiz()
                    
                }
                // добавляем в алерт кнопку
                alert.addAction(action)
                
                // показываем всплывающее окно
                self.present(alert, animated: true, completion: nil)
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
