import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController, ImagesListCellDelegate {
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    
    private var photos: [Photo] = []
    
    @IBOutlet private var tableView: UITableView!
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        imagesListService.fetchPhotosNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard let viewController = segue.destination as? SingleImageViewController,
                  let indexPath = sender as? IndexPath else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let photo = photos[indexPath.row]
            viewController.imageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    @objc private func updateTableViewAnimated() {
        let oldCount = photos.count
        photos = imagesListService.photos // Обновляем photos до batch updates
        let newCount = photos.count
        
        if oldCount != newCount {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.performBatchUpdates {
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        // Блокируем UI, чтобы предотвратить срабатывание гонки
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success:
                    // Обновление массива `photos` после успешного запроса
                    self?.photos = self?.imagesListService.photos ?? []
                    // Обновление ячейки с новым состоянием лайка
                    cell.setIsLiked(self?.photos[indexPath.row].isLiked ?? false)
                case .failure:
                    // Обработка ошибки (например, показ алерта)
                    let alert = UIAlertController(title: "Ошибка", message: "Не удалось изменить лайк.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as! ImagesListCell
        
        // Настройка ячейки
        let photo = photos[indexPath.row]
        cell.delegate = self // Устанавливаем делегат
        
        // Конфигурируем ячейку
        cell.dateLabel.text = photo.createdAt.map { DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none) }
        let likeImage = photo.isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
        cell.cellImage.kf.setImage(with: URL(string: photo.thumbImageURL))
        
        return cell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: UIImage(named: "placeholder")
        ) { [weak self] _ in
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        cell.dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        cell.likeButton.setImage(
            photo.isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off"),
            for: .normal
        )
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageViewWidth = tableView.bounds.width - 32 // Assuming 16pt padding on each side
        let imageWidth = CGFloat(photo.size.width)
        let scale = imageViewWidth / imageWidth
        return CGFloat(photo.size.height) * scale + 8 // Assuming 4pt padding on top and bottom
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }
}
extension ImagesListViewController {
    func toggleLike(for photo: Photo, at indexPath: IndexPath) {
        let isLike = !photo.isLiked
        imagesListService.changeLike(photoId: photo.id, isLike: isLike) { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    // Обновите модель данных
                    self?.photos[indexPath.row].isLiked = isLike
                    // Обновите ячейку таблицы
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            case .failure(let error):
                print("Error updating like status: \(error)")
            }
        }
    }
}


