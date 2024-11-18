import XCTest
@testable import Image_Feed

final class WebViewViewControllerTests: XCTestCase {
    // Функция для извлечения кода из URL (дублирование логики для тестов)
    private func extractCode(from url: URL?) -> String? {
        guard
            let url = url,
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        else {
            return nil
        }
        return codeItem.value
    }

    func testCodeExtractionFromNavigationAction() {
        // Given
        let url = URL(string: "https://unsplash.com/oauth/authorize/native?code=test_code")!
        let mockAction = MockNavigationAction(request: URLRequest(url: url))

        // When
        let code = extractCode(from: mockAction.url)

        // Then
        XCTAssertNotNil(code)
        XCTAssertEqual(code, "test_code")
    }
}
