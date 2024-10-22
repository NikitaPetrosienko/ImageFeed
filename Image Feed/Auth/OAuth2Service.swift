import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init () {}
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let tokenURL = Constants.tokenURL else {
            print("❌ Ошибка: Невозможно создать URL для токена")
            return
        }

        guard var urlComponents = URLComponents(url: tokenURL, resolvingAgainstBaseURL: false) else {
            print("❌ Ошибка: Невозможно создать URLComponents из URL \(tokenURL)")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else {
            print("❌ Ошибка: Невозможно получить URL из URLComponents \(urlComponents)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Ошибка при выполнении запроса: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            // Проверяем статус-код
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                return
            }
            
            // Проверяем данные
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            // Парсим токен из JSON-ответа
            do {
                let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                completion(.success(tokenResponse.access_token))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()  // Запускаем задачу
    }
}

// Ошибки сети
enum NetworkError: Error {
    case httpStatusCode(Int)
    case noData
}

// Структура для декодинга ответа с токеном
struct OAuthTokenResponseBody: Decodable {
    let access_token: String
    let token_type: String
    let scope: String
    let created_at: Int
}


