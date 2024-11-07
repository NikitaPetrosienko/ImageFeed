import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService() // Синглтон
    private init() {}

    private(set) var avatarURL: String? // Свойство для хранения URL аватарки
    
    static let didChangeNotification = Notification.Name("ProfileImageServiceDidChange")

    // Метод для загрузки URL аватарки
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = OAuth2TokenStorage().token else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token not found"])))
            return
        }

        let urlString = "https://api.unsplash.com/users/\(username)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }

            do {
                let userResult = try JSONDecoder().decode(UserResult.self, from: data)
                let profileImageURL = userResult.profileImage.small
                self?.avatarURL = profileImageURL
                completion(.success(profileImageURL))
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": profileImageURL]
                )
            } catch {
                completion(.failure(error))
            }
        }.resume()
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
