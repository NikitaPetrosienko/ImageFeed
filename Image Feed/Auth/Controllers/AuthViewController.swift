import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    weak var delegate: AuthViewControllerDelegate?
    private let oauth2Service = OAuth2Service.shared
    private let tokenStorage = OAuth2TokenStorage()
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard !UIBlockingProgressHUD.isVisible else { return }
        UIBlockingProgressHUD.show()
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
        UIBlockingProgressHUD.show()  // Показываем индикатор загрузки
        oauth2Service.fetchOAuthToken(code) { result in
            UIBlockingProgressHUD.dismiss()  // Скрываем индикатор после завершения запроса
            switch result {
            case .success(let token):
                print("Токен успешно получен: \(token)")
                self.saveToken(token)
            case .failure(let error):
                print("Ошибка при получении токена: \(error)")
                self.showAuthErrorAlert()  // Показываем сообщение об ошибке
            }
        }
    }
    
    private func showAuthErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }

    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true, completion: nil)
    }
}
