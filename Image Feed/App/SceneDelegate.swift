import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
        window.makeKeyAndVisible()
    }

    func showAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            print("Ошибка: AuthViewController не найден")
            return
        }
        let navigationController = UINavigationController(rootViewController: authViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func showMainViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as? UITabBarController else {
            print("Ошибка: TabBarController не найден")
            return
        }
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
}

// Расширение для обработки успешной авторизации
extension SceneDelegate: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        showMainViewController()
    }
}
