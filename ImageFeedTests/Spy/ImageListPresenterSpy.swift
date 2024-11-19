import Foundation
@testable import Image_Feed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?

    var viewDidLoadCalled = false
    var fetchNextPhotosCalled = false
    var toggleLikeCalled = false
    var photoRequestedIndex: Int?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func numberOfPhotos() -> Int {
        return 10
    }

    func photo(at index: Int) -> Photo {
        photoRequestedIndex = index
        return Photo(
            id: "test_id_\(index)",
            size: CGSize(width: 300, height: 300),
            createdAt: Date(),
            welcomeDescription: "Test description",
            thumbImageURL: "https://example.com/thumb.jpg",
            largeImageURL: "https://example.com/large.jpg",
            isLiked: false,
            fullImageURL: "https://example.com/full.jpg"
        )
    }

    func fetchNextPhotos() {
        fetchNextPhotosCalled = true
    }

    func toggleLike(for index: Int) {
        toggleLikeCalled = true
        photoRequestedIndex = index
    }
}
