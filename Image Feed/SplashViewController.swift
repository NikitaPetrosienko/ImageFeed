import UIKit

final class SplashViewController: UIViewController {

    private let storage = OAuth2TokenStorage()  // Хранилище токенов

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Проверяем наличие токена в хранилище
        if let token = storage.token {
            print("Токен найден: \(token)")
            switchToTabBarController()  // Перенаправляем в галерею
        } else {
            performSegue(withIdentifier: "ShowAuthScreen", sender: nil)  // Переход на экран авторизации
        }
    }
    
    // Переход на TabBarController (галерею)
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }

    // Подготовка перехода на экран авторизации
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAuthScreen" {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let authViewController = navigationController.viewControllers.first as? AuthViewController
            else {
                return
            }
            authViewController.delegate = self  // Устанавливаем делегат
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// Реализация делегата AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in
            self?.switchToTabBarController()  // Переход в галерею после успешной авторизации
        }
    }
}
