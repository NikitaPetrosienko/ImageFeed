import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService() // Синглтон
    private init() {}
    
    private(set) var avatarURL: String? // Свойство для хранения URL аватарки
    
    static let didChangeNotification = Notification.Name("ProfileImageServiceDidChange")
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = OAuth2TokenStorage().token else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token not found"])
            print("[ProfileImageService]: Token error - \(error.localizedDescription)") // Лог отсутствия токена
            completion(.failure(error))
            return
        }
        
        let urlString = "https://api.unsplash.com/users/\(username)"
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            print("[ProfileImageService]: URL error - \(error.localizedDescription)") // Лог ошибки URL
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            if let error = error {
                print("[ProfileImageService]: Network error - \(error.localizedDescription)") // Лог ошибки сети
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])
                print("[ProfileImageService]: No data received") // Лог отсутствия данных
                completion(.failure(error))
                return
            }
            
            do {
                let userResult = try JSONDecoder().decode(UserResult.self, from: data)
                let profileImageURL = userResult.profileImage.small
                self?.avatarURL = profileImageURL
                print("[ProfileImageService]: Avatar URL fetched - \(profileImageURL)") // Лог успешного получения URL
                completion(.success(profileImageURL))
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": profileImageURL]
                    
                )
                print("[ProfileImageService]: Notification posted with URL: \(profileImageURL)")
            } catch {
                print("[ProfileImageService]: Decoding error - \(error.localizedDescription)") // Лог ошибки декодирования
                completion(.failure(error))
            }
        }.resume()
    }
    func clearData() {
        avatarURL = nil  // Удаляем URL аватара
        print("ProfileImageService: Данные профиля очищены")
    }
}


// Модель для декодирования ответа
struct UserResult: Codable {
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String
}
