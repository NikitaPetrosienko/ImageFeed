import XCTest
@testable import Image_Feed

final class ProfilePresenterTests: XCTestCase {
    var presenterSpy: ProfilePresenterSpy!
    var viewControllerSpy: ProfileViewControllerSpy!

    override func setUp() {
        super.setUp()
        viewControllerSpy = ProfileViewControllerSpy()
        presenterSpy = ProfilePresenterSpy()
        presenterSpy.view = viewControllerSpy
    }

    override func tearDown() {
        presenterSpy = nil
        viewControllerSpy = nil
        super.tearDown()
    }

    func testViewDidLoadCallsUpdateProfile() {
        // When
        presenterSpy.viewDidLoad()

        // Then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled, "Метод viewDidLoad должен быть вызван")
    }

    func testUpdateAvatarCallsViewUpdateAvatar() {
        // When
        presenterSpy.updateAvatar()

        // Then
        XCTAssertTrue(presenterSpy.updateAvatarCalled, "Метод updateAvatar должен быть вызван")
    }

    func testLogoutCallsShowLogoutConfirmation() {
        // When
        presenterSpy.logoutTapped()

        // Then
        XCTAssertTrue(presenterSpy.logoutTappedCalled, "Метод logoutTapped должен быть вызван")
    }
}
