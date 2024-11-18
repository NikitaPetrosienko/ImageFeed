import XCTest
@testable import Image_Feed

final class ImagesListPresenterTests: XCTestCase {
    var presenter: ImagesListPresenterSpy!
    var viewControllerSpy: ImagesListViewControllerSpy!

    override func setUp() {
        super.setUp()
        presenter = ImagesListPresenterSpy()
        viewControllerSpy = ImagesListViewControllerSpy()
        presenter.view = viewControllerSpy
    }

    override func tearDown() {
        presenter = nil
        viewControllerSpy = nil
        super.tearDown()
    }

    func testViewDidLoadCallsFetchNextPhotos() {
        // When
        presenter.viewDidLoad()

        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled, "Метод viewDidLoad() должен быть вызван")
    }

    func testFetchNextPhotosCalled() {
        // When
        presenter.fetchNextPhotos()

        // Then
        XCTAssertTrue(presenter.fetchNextPhotosCalled, "Метод fetchNextPhotos() должен быть вызван")
    }

    func testPhotoAtIndexReturnsCorrectPhoto() {
        // When
        let photo = presenter.photo(at: 2)

        // Then
        XCTAssertEqual(photo.id, "test_id_2", "Должен вернуться photo с id 'test_id_2'")
        XCTAssertEqual(presenter.photoRequestedIndex, 2, "Должен запроситься photo на индексе 2")
    }

    func testToggleLikeCalledForPhoto() {
        // When
        presenter.toggleLike(for: 5)

        // Then
        XCTAssertTrue(presenter.toggleLikeCalled, "Метод toggleLike(for:) должен быть вызван")
        XCTAssertEqual(presenter.photoRequestedIndex, 5, "Должен запроситься like для photo на индексе 5")
    }
}
