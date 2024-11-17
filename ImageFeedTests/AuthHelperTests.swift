import XCTest
@testable import Image_Feed

final class AuthHelperTests: XCTestCase {
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

    func testAuthRequestURL() {
        // Given
        let configuration = AuthConfiguration.standard
        let helper = AuthHelper(configuration: configuration)

        // When
        let request = helper.authRequest()

        // Then
        XCTAssertNotNil(request.url)
        XCTAssertEqual(request.url?.scheme, "https")
        XCTAssertEqual(request.url?.host, "unsplash.com")
        XCTAssertTrue(request.url?.absoluteString.contains("client_id") ?? false)
    }

    func testCodeExtraction() {
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
