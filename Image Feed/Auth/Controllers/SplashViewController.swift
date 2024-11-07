import UIKit

final class SplashViewController: UIViewController {
    private let profileService = ProfileService.shared
    private let storage = OAuth2TokenStorage()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            performSegue(withIdentifier: "ShowAuthScreen", sender: nil)
        }
    }
    
    private func fetchProfile(token: String) {
        DispatchQueue.main.async {
            UIBlockingProgressHUD.show()
        }
        
        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss() // Также на главном потоке
            }
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                    self.switchToTabBarController()
                case .failure(let error):
                    print("Ошибка при загрузке профиля: \(error)")
                }
            }
        }
    }
    
    private func switchToTabBarController() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("Invalid window configuration")
                return
            }
            
            let tabBarController = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "TabBarViewController")
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAuthScreen" {
            guard let navigationController = segue.destination as? UINavigationController,
                  let authViewController = navigationController.viewControllers.first as? AuthViewController else {
                return
            }
            authViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let token = self.storage.token {
                    self.fetchProfile(token: token)
                }
            }
        }
    }
    
    
    
}

