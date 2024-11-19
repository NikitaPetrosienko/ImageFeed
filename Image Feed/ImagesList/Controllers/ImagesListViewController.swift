import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func reloadCell(at index: Int)
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    var presenter: ImagesListPresenterProtocol?

    @IBOutlet private var tableView: UITableView! {
        didSet {
            tableView.accessibilityIdentifier = "feedTable"
        }
    }

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        presenter?.view = self
        presenter?.viewDidLoad()
    }

    private func setupTableView() {
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier,
           let destinationVC = segue.destination as? SingleImageViewController,
           let indexPath = sender as? IndexPath {
            let photo = presenter?.photo(at: indexPath.row)
            destinationVC.imageURL = URL(string: photo?.largeImageURL ?? "")
        }
    }

    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        guard newCount > oldCount else { return }
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        
        // Проверяем корректность данных перед обновлением
        tableView.performBatchUpdates({
            if tableView.numberOfRows(inSection: 0) == oldCount {
                tableView.insertRows(at: indexPaths, with: .automatic)
            } else {
                tableView.reloadData()
            }
        })
    }

    func reloadCell(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        if tableView.numberOfRows(inSection: 0) > index {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.numberOfPhotos() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as! ImagesListCell
        cell.selectionStyle = .none
        if let photo = presenter?.photo(at: indexPath.row) {
            cell.delegate = self
            cell.dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
            cell.likeButton.setImage(
                photo.isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off"),
                for: .normal
            )
            cell.cellImage.kf.setImage(with: URL(string: photo.thumbImageURL))
            cell.likeButton.accessibilityIdentifier = "likeButton"

        }
        return cell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (presenter?.numberOfPhotos() ?? 0) - 1 {
            presenter?.fetchNextPhotos()
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.toggleLike(for: indexPath.row)
    }
}
