import Foundation

protocol ProfileViewControllerProtocol: AnyObject {
    func updateProfile(name: String, login: String, bio: String?)
    func updateAvatar(url: URL?)
    func showLogoutConfirmation()
}

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func logoutTapped()
    func performLogout()
    func updateAvatar()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        updateProfile()
        observeProfileImageUpdates()
    }
    
    private func updateProfile() {
        guard let profile = profileService.profile else {
            profileService.loadProfile { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.updateProfile() // Повторный вызов после успешной загрузки
                    case .failure(let error):
                        print("Failed to load profile: \(error.localizedDescription)")
                    }
                }
            }
            return
        }
        view?.updateProfile(
            name: profile.name.isEmpty ? "Неизвестный пользователь" : profile.name,
            login: profile.loginName,
            bio: profile.bio ?? "Описание отсутствует"
        )
    }
    
    private func observeProfileImageUpdates() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
        updateAvatar()
    }
    
    func updateAvatar() {
        guard let avatarURLString = profileImageService.avatarURL,
              let avatarURL = URL(string: avatarURLString) else { return }
        view?.updateAvatar(url: avatarURL)
    }
    
    func logoutTapped() {
        view?.showLogoutConfirmation()
    }
    
    func performLogout() {
        ProfileLogoutService.shared.logout {
            print("Logged out successfully")
        }
    }
}
