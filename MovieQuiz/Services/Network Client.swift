import Foundation

struct NetworkClient {
    // Перечисление для описания возможных сетевых ошибок
    private enum NetworkError: Error {
        case codeError // Ошибка, связанная с неподходящим статус-кодом ответа
    }
    
    // Функция для выполнения сетевого запроса
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url) // Создаем запрос на основе URL
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Проверяем, возникла ли ошибка во время выполнения запроса
            if let error = error {
                handler(.failure(error)) // Если ошибка есть, передаем её через handler
                return
            }
            
            // Проверяем, что ответ имеет статус-код 2xx (успех)
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError)) // Если статус-код не успешный, передаем ошибку
                return
            }
            
            // Проверяем, что данные не пустые и передаем их через handler
            guard let data = data else { return }
            handler(.success(data)) // Передаем полученные данные через handler
        }
        task.resume() // Запускаем выполнение задачи
    }
}
