import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
         func show(quiz step: QuizStepViewModel) {
          imageView.image = step.image
          textLabel.text = step.question
          counterLabel.text = step.questionNumber
        }
    }
    //Аутлеты взаимодействия
    @IBAction private func noButton(_ sender: Any) {
    }
    
    @IBAction private func yesButton(_ sender: Any) {
    }
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var textLabel: UILabel!
}


// Структура данных вопросов
struct QuizQuestion {
    let image: String
    // строка с названием фильма,
    // совпадает с названием картинки афиши фильма в Assets
    let text: String
    // строка с вопросом о рейтинге фильма
    let correctAnswer: Bool
    // булевое значение (true, false), правильный ответ на вопрос
}

//Модель для экрана
struct QuizStepViewModel {
  let image: UIImage
  let question: String
  let questionNumber: String
}




//Мокапы
private let questions: [QuizQuestion] = [
    QuizQuestion(image: "The Godfater", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "Dead Pool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
    QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
]

//Номер текущего вопроса
private var currentQuestionIndex = 0

//Количество правильных ответов
private var correctAnswers = 0

private func convert(model: QuizQuestion) -> QuizStepViewModel {
    let questionStep = QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(), question: model.text, questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
    return questionStep
}

// приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает


/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
