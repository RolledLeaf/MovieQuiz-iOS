import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    private var askedQuestionIndices: Set<Int> = []
    
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
                  
                  // Если все фильмы использованы, очищаем список
                  if self.askedQuestionIndices.count == self.movies.count {
                      self.askedQuestionIndices.removeAll()
                  }
                  
                  // Выбираем случайный индекс, который еще не был использован
                  var index: Int
                  repeat {
                      index = (0..<self.movies.count).randomElement() ?? 0
                  } while self.askedQuestionIndices.contains(index)
                  
                  // Добавляем индекс в список заданных вопросов
                  self.askedQuestionIndices.insert(index)
                  
                  guard let movie = self.movies[safe: index] else { return }
                  
                  var imageData = Data()
                  do {
                      imageData = try Data(contentsOf: movie.imageURL)
                  } catch {
                      print("Failed to load image")
                  }
                  
                  let actualRating = Float(movie.rating) ?? 0
                  let randomOffset: Float = Bool.random() ? -1.0 : 0.5
                  let comparisonRating = (actualRating + randomOffset).rounded(toPlaces: 1)
                  let isGreaterComparison = Bool.random()
                  let questionText: String
                  
                  if isGreaterComparison {
                      questionText = "Is rating of \(movie.title) more than \(comparisonRating)?"
                  } else {
                      questionText = "Is rating of \(movie.title) less than \(comparisonRating)?"
                  }
                  
                  let correctAnswer = isGreaterComparison ? (actualRating > comparisonRating) : (actualRating < comparisonRating)
                  let question = QuizQuestion(image: imageData, text: questionText, correctAnswer: correctAnswer)
                  
                  DispatchQueue.main.async { [weak self] in
                      guard let self = self else { return }
                      self.delegate?.didReceiveNextQuestion(question: question)
                      self.delegate?.hideLoadingIndicator()
                  }
              }
          }
}

extension Float {
    func rounded(toPlaces places: Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}
