import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "avatar"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let loginNameLabel: UILabel = {
        let label = UILabel()
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
        updateProfileDetails()
        observeProfileImageUpdates()
        updateAvatar()
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
    
    private func observeProfileImageUpdates() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            self.updateAvatar()
        }
    }
    
    private func updateProfileDetails() {
        guard let profile = profileService.profile else {
            print("Profile is not loaded yet. Requesting profile...")
            profileService.loadProfile { [weak self] in
                DispatchQueue.main.async {
                    self?.updateProfileDetails()
                }
            }
            return
        }
        
        nameLabel.text = profile.name.isEmpty ? "Неизвестный пользователь" : profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio ?? "Описание отсутствует"
        
        print("Profile details updated:")
        print("Name: \(profile.name)")
        print("Login Name: \(profile.loginName)")
        print("Bio: \(profile.bio ?? "nil")")
    }
    
    private func updateAvatar() {
        DispatchQueue.main.async {
            guard let avatarURLString = ProfileImageService.shared.avatarURL,
                  let avatarURL = URL(string: avatarURLString) else {
                print("Avatar URL not found or invalid")
                return
            }
            
            self.avatarImageView.kf.setImage(with: avatarURL, placeholder: UIImage(named: "avatar")) { result in
                switch result {
                case .success:
                    print("Avatar successfully loaded")
                case .failure(let error):
                    print("Failed to load avatar: \(error)")
                }
            }
        }
    }
    
    private func setupLogoutButton() {
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
    }

    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        alert.addAction(UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            ProfileLogoutService.shared.logout {
                self.navigateToAuthScreen()
            }
        })
        present(alert, animated: true)
    }

    // Метод для перехода на AuthViewController через Storyboard
    private func navigateToAuthScreen() {
        guard let window = UIApplication.shared.windows.first else {
            print("Ошибка: окно не найдено")
            return
        }
        
        // Завершаем все представленные контроллеры перед установкой нового rootViewController
        if let rootViewController = window.rootViewController {
            rootViewController.dismiss(animated: false) {
                self.setAuthAsRoot(in: window)
            }
        } else {
            self.setAuthAsRoot(in: window)
        }
    }

    private func setAuthAsRoot(in window: UIWindow) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            print("Ошибка: AuthViewController не найден")
            return
        }
        
        authViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: authViewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        print("AuthViewController установлен как rootViewController")
    }
}

extension ProfileViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        // Закрываем экран авторизации после успешного входа
        vc.dismiss(animated: true) {
            // Можно добавить логику, если нужно обновить интерфейс после авторизации
            self.updateProfileDetails()
        }
    }
}
