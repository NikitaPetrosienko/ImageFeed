import XCTest
@testable import Image_Feed

final class ProfileViewControllerTests: XCTestCase {
    var viewController: ProfileViewController!
    var presenterSpy: ProfilePresenterSpy!

    override func setUp() {
        super.setUp()
        viewController = ProfileViewController()
        presenterSpy = ProfilePresenterSpy()
        viewController.configure(presenterSpy) // Подключаем презентер через конфигурацию
    }

    override func tearDown() {
        viewController = nil
        presenterSpy = nil
        super.tearDown()
    }

    func testViewDidLoadCallsPresenterViewDidLoad() {
        // When
        _ = viewController.view

        // Then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled, "Метод viewDidLoad() у презентера должен быть вызван")
    }

    func testLogoutCallsShowLogoutConfirmation() {
        // When
        presenterSpy.logoutTapped()

        // Then
        XCTAssertTrue(presenterSpy.logoutTappedCalled, "Метод logoutTapped() у презентера должен быть вызван")
    }

}
