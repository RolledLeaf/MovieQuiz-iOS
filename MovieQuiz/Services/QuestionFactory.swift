import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    
    init(delegate: QuestionFactoryDelegate?, moviesLoader: MoviesLoading) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let mostPopularMovies):
                self.movies = mostPopularMovies.items // сохраняем фильм в нашу новую переменную
                self.delegate?.didLoadDataFromServer() // сообщаем, что данные загрузились
            case .failure(let error):
                self.delegate?.didFailToLoadData(with: error) // сообщаем об ошибке нашему MovieQuizViewController
            }
        }
    }
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
        remainingQuestions = questions.shuffled()
    }
    
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
    
    private var remainingQuestions: [QuizQuestion] = []
    
    
    var questionsCount: Int {
        return questions.count
    }
    
    func requestNextQuestion()  {
        guard !movies.isEmpty else {
               delegate?.didFailToLoadData(with: NSError(domain: "QuestionFactory", code: -1, userInfo: [NSLocalizedDescriptionKey: "No movies loaded"]))
               return
           }
           
        guard let movie = movies.randomElement() else {
            var alertModel = AlertModel(title: "Ошибка", message: "Не удалось загрузить данные о фильмах. Попробуйте позже", buttonText: "Ok", completion: self.requestNextQuestion)
            return
        }
        
           let questionText = "Рейтинг фильма \(movie.title) больше чем 6?"
           let correctAnswer = Double(movie.rating) ?? 0 > 6.0
           
           let question = QuizQuestion(
               image: movie.imageURL.absoluteString, // Здесь нужно будет скачать изображение по URL или использовать заглушку
               text: questionText,
               correctAnswer: correctAnswer
           )
           
           delegate?.didReceiveNextQuestion(question: question)
    }
    
}
