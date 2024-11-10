import Foundation

final class ImagesListService {
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange") // Уведомление об изменениях
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var isLoading = false
    
    func fetchPhotosNextPage() {
        guard !isLoading else { return } // Проверка на текущую загрузку
        
        isLoading = true // Помечаем, что началась загрузка
        
        // Определяем номер следующей страницы
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        // Создаем URL и запрос
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)&per_page=10") else {
            print("[ImagesListService]: Invalid URL")
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(OAuth2TokenStorage().token ?? "")", forHTTPHeaderField: "Authorization")
        
        // Выполняем сетевой запрос
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            defer { self.isLoading = false } // Устанавливаем isLoading в false после выполнения запроса
            
            if let error = error {
                print("[ImagesListService]: Network error - \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("[ImagesListService]: No data received")
                return
            }
            
            // Декодируем данные
            do {
                let photoResults = try JSONDecoder().decode([PhotoResult].self, from: data)
                
                // Преобразуем PhotoResult в Photo
                let newPhotos = photoResults.map { result in
                    Photo(
                        id: result.id,
                        size: CGSize(width: result.width, height: result.height),
                        createdAt: DateFormatter().date(from: result.createdAt), // Преобразуем дату из строки
                        welcomeDescription: result.description,
                        thumbImageURL: result.urls.thumb,
                        largeImageURL: result.urls.full,
                        isLiked: result.likedByUser
                    )
                }
                
                // Обновляем массив и отправляем уведомление
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos) // Добавляем в конец массива
                    self.lastLoadedPage = nextPage // Обновляем номер загруженной страницы
                    
                    // Отправляем уведомление об изменении
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
            } catch {
                print("[ImagesListService]: Decoding error - \(error)")
            }
        }
        
        task.resume() // Запуск задачи
    }
}


struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
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
