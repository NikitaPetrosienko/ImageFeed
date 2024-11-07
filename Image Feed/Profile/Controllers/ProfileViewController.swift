import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "avatar"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35 // Половина от высоты/ширины для создания круга
        imageView.layer.masksToBounds = true // Обрезает изображение за пределами круга
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
            print("Profile is not loaded yet. Requesting profile...") // Лог запроса профиля
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
        
        print("Profile details updated:") // Лог обновления профиля
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
            
            print("Loading avatar from URL: \(avatarURL)")
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
    
    
}
