import XCTest
@testable import Image_Feed

final class ImagesListViewControllerTests: XCTestCase {
    var viewController: ImagesListViewController!
    var presenterSpy: ImagesListPresenterSpy!

    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as? ImagesListViewController
        presenterSpy = ImagesListPresenterSpy()
        viewController.presenter = presenterSpy
        _ = viewController.view // Trigger viewDidLoad
    }

    override func tearDown() {
        viewController = nil
        presenterSpy = nil
        super.tearDown()
    }

    func testViewDidLoadCallsPresenterViewDidLoad() {
        // Then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled, "Метод viewDidLoad() у презентера должен быть вызван")
    }

    func testUpdateTableViewAnimatedCalled() {
        // Given
        let spy = ImagesListViewControllerSpy()
        presenterSpy.view = spy

        // When
        spy.updateTableViewAnimated(oldCount: 5, newCount: 10)

        // Then
        XCTAssertTrue(spy.updateTableViewAnimatedCalled, "Метод updateTableViewAnimated должен быть вызван")
        XCTAssertEqual(spy.updatedOldCount, 5, "Должно обновиться с oldCount = 5")
        XCTAssertEqual(spy.updatedNewCount, 10, "Должно обновиться до newCount = 10")
    }

    func testReloadCellCalled() {
        // Given
        let spy = ImagesListViewControllerSpy()
        presenterSpy.view = spy

        // When
        spy.reloadCell(at: 3)

        // Then
        XCTAssertTrue(spy.reloadCellCalled, "Метод reloadCell должен быть вызван")
        XCTAssertEqual(spy.reloadedCellIndex, 3, "Ячейка с индексом 3 должна быть перезагружена")
    }
}
