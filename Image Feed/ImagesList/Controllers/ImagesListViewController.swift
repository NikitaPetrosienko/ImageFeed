import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    
    @IBOutlet private var tableView: UITableView!
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
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
        if segue.identifier == showSingleImageSegueIdentifier,
           let destinationVC = segue.destination as? SingleImageViewController,
           let indexPath = sender as? IndexPath {
            let photo = photos[indexPath.row]
            destinationVC.imageURL = URL(string: photo.largeImageURL)
        }
    }
    
    @objc private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newPhotos = imagesListService.photos

        guard newPhotos.count > oldCount else { return } // Убедимся, что есть новые данные

        let indexPaths = (oldCount..<newPhotos.count).map { IndexPath(row: $0, section: 0) }
        
        photos = newPhotos // Обновляем массив до обновления таблицы

        tableView.performBatchUpdates({
            tableView.insertRows(at: indexPaths, with: .automatic)
        }, completion: nil)
    }

}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as! ImagesListCell
        cell.selectionStyle = .none // Убираем выделение при нажатии
        let photo = photos[indexPath.row]
        cell.delegate = self
        cell.dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        cell.likeButton.setImage(
            photo.isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off"),
            for: .normal
        )
        cell.cellImage.kf.setImage(with: URL(string: photo.thumbImageURL))
        return cell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
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
                    self?.photos[indexPath.row].isLiked = isLike
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            case .failure(let error):
                print("Error updating like status: \(error)")
            }
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        toggleLike(for: photo, at: indexPath)
    }
}
