import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    weak var delegate: AuthViewControllerDelegate?
    private let oauth2Service = OAuth2Service.shared
    private let tokenStorage = OAuth2TokenStorage()
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowWebView", sender: nil)  // Переход к WebView для авторизации
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()

        if let token = tokenStorage.token {
            print("Токен найден: \(token)")
        } else {
            print("Токен не найден, требуется авторизация")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowWebView" {
            guard let webViewVC = segue.destination as? WebViewViewController else { return }
            webViewVC.delegate = self  // Устанавливаем делегат для получения кода авторизации
        }
    }

    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
    }

    private func saveToken(_ token: String) {
        tokenStorage.token = token
        print("Токен сохранен: \(token)")

        DispatchQueue.main.async {
            if let delegate = self.delegate {
                print("Вызывается делегат didAuthenticate")
                delegate.didAuthenticate(self)
            } else {
                print("Делегат не установлен")
            }
        }
    }}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        print("Авторизация успешна, получен код: \(code)")
        oauth2Service.fetchOAuthToken(code: code) { result in
            switch result {
            case .success(let token):
                print("Токен успешно получен: \(token)")
                self.saveToken(token)  // Сохраняем токен
            case .failure(let error):
                print("Ошибка при получении токена: \(error)")
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true, completion: nil)
    }
}
