import Foundation
@testable import Image_Feed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var updateProfileCalled = false
    var updateAvatarCalled = false
    var showLogoutConfirmationCalled = false
    var redirectToAuthScreenCalled = false

    func updateProfile(name: String, login: String, bio: String?) {
        updateProfileCalled = true
    }

    func updateAvatar(url: URL?) {
        updateAvatarCalled = true
    }

    func showLogoutConfirmation() {
        showLogoutConfirmationCalled = true
    }

    func redirectToAuthScreen() {
        redirectToAuthScreenCalled = true
    }
}
