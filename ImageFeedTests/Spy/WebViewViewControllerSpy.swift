import Foundation
@testable import Image_Feed

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    private(set) var loadRequestCalled = false
    private(set) var request: URLRequest?

    func load(request: URLRequest) {
        loadRequestCalled = true
        self.request = request
    }

    func setProgressValue(_ newValue: Float) {
        // Пустая реализация для теста
    }

    func setProgressHidden(_ isHidden: Bool) {
        // Пустая реализация для теста
    }
}
