import Foundation
@testable import Image_Feed

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?

    var viewDidLoadCalled = false
    var logoutTappedCalled = false
    var performLogoutCalled = false
    var updateAvatarCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func logoutTapped() {
        logoutTappedCalled = true
    }

    func performLogout() {
        performLogoutCalled = true
    }

    func updateAvatar() {
        updateAvatarCalled = true
    }
}
