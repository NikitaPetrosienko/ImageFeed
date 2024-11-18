import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func numberOfPhotos() -> Int
    func photo(at index: Int) -> Photo
    func fetchNextPhotos()
    func toggleLike(for index: Int)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared

    func viewDidLoad() {
        fetchNextPhotos()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updatePhotos),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
    }

    @objc private func updatePhotos() {
        let oldCount = photos.count
        photos = imagesListService.photos
        let newCount = photos.count
        view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
    }

    func numberOfPhotos() -> Int {
        return photos.count
    }

    func photo(at index: Int) -> Photo {
        return photos[index]
    }

    func fetchNextPhotos() {
        imagesListService.fetchPhotosNextPage { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.updatePhotos()
            case .failure(let error):
                print("Failed to fetch photos: \(error.localizedDescription)")
            }
        }
    }

    func toggleLike(for index: Int) {
        let photo = photos[index]
        let isLike = !photo.isLiked
        imagesListService.changeLike(photoId: photo.id, isLike: isLike) { [weak self] result in
            switch result {
            case .success:
                self?.photos[index].isLiked = isLike
                DispatchQueue.main.async {
                    self?.view?.reloadCell(at: index)
                }
            case .failure(let error):
                print("Error updating like status: \(error)")
            }
        }
    }
}
