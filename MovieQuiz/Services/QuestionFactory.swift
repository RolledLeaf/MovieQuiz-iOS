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
        let timeoutInterval: TimeInterval = 10.0
        let timeoutWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.delegate?.didFailToLoadData(with: NSError(domain: "QuestionFactory", code: -1, userInfo: [NSLocalizedDescriptionKey: "Время ожидания загрузки вышло"]))
            //Остановка анимации загрузки
            DispatchQueue.main.async {
                self.delegate?.hideLoadingIndicator()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + timeoutInterval, execute: timeoutWorkItem)
        moviesLoader.loadMovies { [weak self] result in
            timeoutWorkItem.cancel()
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
    private let questions: [QuizQuestion] = []
    private var remainingQuestions: [QuizQuestion] = []
    var questionsCount: Int {
        return questions.count
    }
    
    func requestNextQuestion() {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.showLoadingIndicator()
        }
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            guard let movie = self.movies[safe: index] else { return }
            var imageData = Data()
            do {
                imageData = try Data(contentsOf: movie.imageURL)
            } catch {
                print("Failed to load image")
          
            }
            let rating = Float(movie.rating) ?? 0
            let text = "Рейтинг фильма \(movie.title) больше 7?"
            let correctAnswer = rating > 7
            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
                self.delegate?.hideLoadingIndicator()
            }
        }
    }
}
