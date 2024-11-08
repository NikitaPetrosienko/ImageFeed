import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    private(set) static var isVisible: Bool = false

    static func show() {
        guard !isVisible else { return }
        isVisible = true
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()  // Показываем индикатор
    }
    
    static func dismiss() {
        guard isVisible else { return }
        isVisible = false
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()  // Скрываем индикатор
    }
}
