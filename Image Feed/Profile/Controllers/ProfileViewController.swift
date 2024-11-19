import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    var presenter: ProfilePresenterProtocol?
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }

    private var animationLayers = [CALayer]() // Для хранения слоев анимации
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "avatar"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "nameLabel"
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "loginNameLabel"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .custom)
        button.accessibilityIdentifier = "logoutButton"
        button.translatesAutoresizingMaskIntoConstraints = false
        if let buttonImage = UIImage(named: "logout_button") {
            button.setImage(buttonImage, for: .normal)
        }
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YPBlack")
        
        setupViews()
        addGradientAnimations() // Добавляем анимации при загрузке
        presenter?.viewDidLoad()
        setupLogoutButton()
    }
    
    private func setupViews() {
        view.addSubview(avatarImageView)
        view.addSubview(nameLabel)
        view.addSubview(loginNameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupLogoutButton() {
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }
    
    @objc func logoutTapped() {
        presenter?.logoutTapped()
    }
    
    func redirectToAuthScreen() {
        guard let window = UIApplication.shared.windows.first else {
            print("Ошибка: окно не найдено")
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            print("Ошибка: AuthViewController не найден")
            return
        }

        let navigationController = UINavigationController(rootViewController: authViewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

// MARK: - Gradient Animations
extension ProfileViewController {
    private func createGradientLayer(for frame: CGRect, cornerRadius: CGFloat) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.cornerRadius = cornerRadius
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)

        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")

        return gradient
    }
    
    private func addGradientAnimations() {
        guard animationLayers.isEmpty else { return }

        let avatarGradient = createGradientLayer(for: avatarImageView.bounds, cornerRadius: 35)
        avatarImageView.layer.addSublayer(avatarGradient)
        animationLayers.append(avatarGradient)

        let nameGradient = createGradientLayer(for: nameLabel.bounds, cornerRadius: 0)
        nameLabel.layer.addSublayer(nameGradient)
        animationLayers.append(nameGradient)

        let loginGradient = createGradientLayer(for: loginNameLabel.bounds, cornerRadius: 0)
        loginNameLabel.layer.addSublayer(loginGradient)
        animationLayers.append(loginGradient)

        let descriptionGradient = createGradientLayer(for: descriptionLabel.bounds, cornerRadius: 0)
        descriptionLabel.layer.addSublayer(descriptionGradient)
        animationLayers.append(descriptionGradient)
    }

    private func removeGradientAnimations() {
        animationLayers.forEach { $0.removeFromSuperlayer() }
        animationLayers.removeAll()
    }
}

// MARK: - ProfileViewControllerProtocol
extension ProfileViewController: ProfileViewControllerProtocol {
    func updateProfile(name: String, login: String, bio: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.nameLabel.text = name
            self?.loginNameLabel.text = login
            self?.descriptionLabel.text = bio ?? "Описание отсутствует"
            self?.removeGradientAnimations()
        }
    }

    func updateAvatar(url: URL?) {
        DispatchQueue.main.async { [weak self] in
            self?.avatarImageView.kf.setImage(with: url, placeholder: UIImage(named: "avatar"))
            self?.removeGradientAnimations()
        }
    }

    func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            preferredStyle: .alert
        )
        
        // Кнопка "Нет"
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel)
        alert.addAction(cancelAction)
        
        // Кнопка "Да"
        let confirmAction = UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
            self?.presenter?.performLogout()
        }
        alert.addAction(confirmAction)
        
        // Устанавливаем идентификаторы через view после презентации
        DispatchQueue.main.async {
            if let alertView = alert.view {
                alertView.accessibilityIdentifier = "logoutAlert"
            }
            if let cancelButton = alert.actions.first(where: { $0.title == "Нет" })?.value(forKey: "__representer") as? NSObject {
                cancelButton.setValue("cancelLogoutButton", forKey: "accessibilityIdentifier")
            }
            if let confirmButton = alert.actions.first(where: { $0.title == "Да" })?.value(forKey: "__representer") as? NSObject {
                confirmButton.setValue("confirmLogoutButton", forKey: "accessibilityIdentifier")
            }
        }
        
        present(alert, animated: true)
    }


}
