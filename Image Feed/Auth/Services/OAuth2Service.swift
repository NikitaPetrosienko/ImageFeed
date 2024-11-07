import Foundation

// Ошибки, которые могут возникнуть при авторизации
enum AuthServiceError: Error {
    case invalidRequest
}

// Класс, выполняющий авторизацию через OAuth2
final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private let urlSession = URLSession.shared             // URLSession для выполнения запросов
    private var task: URLSessionTask?                      // Переменная для отслеживания текущей задачи
    private var lastCode: String?                          // Последний использованный код авторизации
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread) // Проверка потока, убедитесь, что вызывается на главном
        
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        // Показываем индикатор активности на главном потоке
        DispatchQueue.main.async {
            UIBlockingProgressHUD.show()
        }
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            DispatchQueue.main.async {
                completion(.failure(AuthServiceError.invalidRequest))
                UIBlockingProgressHUD.dismiss()
            }
            return
        }
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss() // Должен быть на главном

                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                    completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                    return
                }

                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }

                do {
                    let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(tokenResponse.access_token))
                } catch {
                    completion(.failure(error))
                }

                self?.task = nil
                self?.lastCode = nil
            }
        }

        
        self.task = task
        task.resume()
    }



    
    
    // Функция для создания URLRequest с заданным кодом авторизации
    // Функция для создания URLRequest с заданным кодом авторизации
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Формируем тело запроса с нужными параметрами
        let requestBodyComponents = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        request.httpBody = requestBodyComponents
            .map { "\($0)=\($1)" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        return request
    }
    
}

// Ошибки, которые могут возникнуть при сетевом запросе
enum NetworkError: Error {
    case httpStatusCode(Int)
    case noData
}

// Структура для декодирования ответа с токеном
struct OAuthTokenResponseBody: Decodable {
    let access_token: String
    let token_type: String
    let scope: String
    let created_at: Int
}

