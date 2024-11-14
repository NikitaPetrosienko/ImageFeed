import Foundation
import UIKit

final class ImagesListService {
    static let shared = ImagesListService()
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var isLoading = false
    
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    private init() {}
    
    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        
        isLoading = true
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)&per_page=10") else {
            print("[ImagesListService]: Invalid URL")
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(OAuth2TokenStorage().token ?? "")", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            defer { self.isLoading = false }
            
            if let error = error {
                print("[ImagesListService]: Network error - \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("[ImagesListService]: No data received")
                return
            }
            
            do {
                let photoResults = try JSONDecoder().decode([PhotoResult].self, from: data)
                
                let newPhotos = photoResults.map { result in
                    Photo(
                        id: result.id,
                        size: CGSize(width: result.width, height: result.height),
                        createdAt: self.dateFormatter.date(from: result.createdAt),
                        welcomeDescription: result.description,
                        thumbImageURL: result.urls.thumb,
                        largeImageURL: result.urls.full,
                        isLiked: result.likedByUser,
                        fullImageURL: result.urls.full
                    )
                }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
            } catch {
                print("[ImagesListService]: Decoding error - \(error)")
            }
        }
        
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        let endpoint = isLike ? "like" : "like"
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/\(endpoint)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(OAuth2TokenStorage().token ?? "")", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                    completion(.success(()))
                } else {
                    let error = NSError(
                        domain: "",
                        code: httpResponse.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to change like status with status code \(httpResponse.statusCode)"]
                    )
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    func clearData() {
        photos.removeAll()
        print("ImagesListService: Данные очищены")
    }
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
    let fullImageURL: String
}

struct PhotoResult: Codable {
    let id: String
    let createdAt: String
    let width: Int
    let height: Int
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case description
        case urls
        case likedByUser = "liked_by_user"
    }
}

struct UrlsResult: Codable {
    let thumb: String
    let full: String
}
