import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imagesListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton! {
        didSet {
            likeButton.accessibilityIdentifier = "likeButton"
        }
    }
    @IBOutlet var dateLabel: UILabel!
    
    private var gradientLayer: CAGradientLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        likeButton.addTarget(self, action: #selector(likeButtonClicked), for: .touchUpInside)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        removeGradientAnimation()
    }
    
    func configure(with imageUrl: URL?, isLiked: Bool) {
        setIsLiked(isLiked)
        
        if let imageUrl = imageUrl {
            addGradientAnimation() // Добавляем анимацию до загрузки
            
            cellImage.kf.setImage(with: imageUrl, completionHandler: { [weak self] result in
                self?.removeGradientAnimation() // Удаляем анимацию после загрузки
                
                if case .failure(let error) = result {
                    print("Ошибка загрузки изображения: \(error)")
                }
            })
        } else {
            cellImage.image = UIImage(named: "placeholder") // Плейсхолдер для изображения
        }
    }
    
    private func addGradientAnimation() {
        gradientLayer = CAGradientLayer()
        gradientLayer?.frame = cellImage.bounds
        gradientLayer?.colors = [
            UIColor.lightGray.cgColor,
            UIColor.darkGray.cgColor,
            UIColor.lightGray.cgColor
        ]
        gradientLayer?.locations = [0, 0.5, 1]
        gradientLayer?.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer?.endPoint = CGPoint(x: 1, y: 0.5)
        
        // Анимация
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0, 0.5, 1]
        animation.toValue = [0, 1, 1]
        animation.duration = 1.0
        animation.repeatCount = .infinity
        gradientLayer?.add(animation, forKey: "locations")
        
        cellImage.layer.addSublayer(gradientLayer!)
    }
    
    private func removeGradientAnimation() {
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
    }
    
    @objc private func likeButtonClicked() {
        delegate?.imagesListCellDidTapLike(self)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let imageName = isLiked ? "like_button_on" : "like_button_off"
        likeButton.setImage(UIImage(named: imageName), for: .normal)
    }
}
