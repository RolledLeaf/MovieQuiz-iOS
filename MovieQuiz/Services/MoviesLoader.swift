import Foundation

protocol MoviesLoading {
    // Протокол для загрузки фильмов с определённым handler'ом
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    private let networkClient = NetworkClient() // Создаем экземпляр сетевого клиента
    
    // Конструируем URL для запроса списка популярных фильмов
    private var mostPopularMoviesUrl: URL {
        guard let url = URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl") // Вызываем ошибку, если URL не удается создать
        }
        return url
    }
    
    // Функция для загрузки фильмов
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    // Декодируем полученные данные в экземпляр структуры MostPopularMovies
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies)) // Передаем успешный результат с декодированными данными
                } catch {
                    handler(.failure(error)) // Если декодирование не удалось, передаем ошибку
                }
            case .failure(let error):
                handler(.failure(error)) // Передаем ошибку, возникшую при загрузке данных
            }
        }
    }
}
