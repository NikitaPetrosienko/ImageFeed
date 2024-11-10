import UIKit

final class ImagesListViewController: UIViewController {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    @IBOutlet private var tableView: UITableView!
    
    private let imagesListService = ImagesListService() // Подключаем сервис
    private var photos: [Photo] = [] // Массив для хранения фотографий
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Подписываемся на уведомления об изменении списка фотографий
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updatePhotos),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        imagesListService.fetchPhotosNextPage() // Загружаем первую страницу
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    // Обновление данных при получении новых фотографий
    @objc private func updatePhotos() {
        photos = imagesListService.photos
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            // Передаем URL изображения в контроллер
            let photo = photos[indexPath.row]
            viewController.imageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
} 

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        cell.dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        
        let likeImage = photo.isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
        
        // Загрузка изображения
        if let thumbURL = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.setImage(with: thumbURL)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        
        // Ширина доступного пространства для изображения в ячейке
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        
        // Пропорциональное масштабирование по ширине
        let imageWidth = photo.size.width
        let imageHeight = photo.size.height
        let scale = imageViewWidth / imageWidth
        let cellHeight = imageHeight * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Проверяем, нужно ли подгружать следующую страницу
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

