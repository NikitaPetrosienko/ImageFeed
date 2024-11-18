@testable import Image_Feed
import XCTest

final class WebViewTests: XCTestCase {

    // Проверяем вызов viewDidLoad презентера
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    func testPresenterCallsLoadRequest() {
        // given
        let authHelper = AuthHelper(configuration: .standard)
        let presenter = WebViewPresenter(authHelper: authHelper)
        let viewControllerSpy = WebViewViewControllerSpy()
        presenter.view = viewControllerSpy

        // when
        presenter.viewDidLoad()

        // then
        XCTAssertTrue(viewControllerSpy.loadRequestCalled, "Метод loadRequest не был вызван")
        XCTAssertNotNil(viewControllerSpy.request, "URLRequest не был передан")
    }
    func testProgressVisibleWhenLessThenOne() {
        // given
        let authHelper = AuthHelper(configuration: .standard)
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6

        // when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)

        // then
        XCTAssertFalse(shouldHideProgress, "Progress должен быть видимым при значении меньше 1")
    }
    func testProgressHiddenWhenOne() {
        // given
        let authHelper = AuthHelper(configuration: .standard)
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0

        // when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)

        // then
        XCTAssertTrue(shouldHideProgress, "Progress должен быть скрыт при значении 1")
    }
    func testAuthHelperAuthURL() {
        // given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)

        // when
        let url = authHelper.authURL()
        let urlString = url?.absoluteString ?? ""

        // then
        XCTAssertTrue(urlString.contains(configuration.authorizeURL), "URL должен содержать базовый адрес")
        XCTAssertTrue(urlString.contains(configuration.accessKey), "URL должен содержать accessKey")
        XCTAssertTrue(urlString.contains(configuration.redirectURI), "URL должен содержать redirectURI")
        XCTAssertTrue(urlString.contains("code"), "URL должен содержать тип ответа code")
        XCTAssertTrue(urlString.contains(configuration.accessScope), "URL должен содержать scope")
    }
    func testCodeFromURL() {
        // given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)

        // Создаём URL с параметром code
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")
        urlComponents?.queryItems = [
            URLQueryItem(name: "code", value: "test_code")
        ]
        let url = urlComponents?.url!

        // when
        let code = authHelper.code(from: url!)

        // then
        XCTAssertEqual(code, "test_code", "Метод должен корректно извлекать параметр code из URL")
    }
    

}

// Мок презентера для проверки связи
final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled = false
    weak var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {}
    func code(from url: URL) -> String? { return nil }
}
