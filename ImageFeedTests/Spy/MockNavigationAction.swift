import Foundation

// Протокол для тестирования NavigationAction
protocol TestNavigationActionProtocol {
    var url: URL? { get }
}

// Мок для TestNavigationActionProtocol
final class MockNavigationAction: TestNavigationActionProtocol {
    let url: URL?

    init(request: URLRequest) {
        self.url = request.url
    }
}
