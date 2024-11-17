import Foundation
import WebKit

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest
    func code(from navigationAction: WKNavigationAction) -> String?
}

class AuthHelper: AuthHelperProtocol {
    private let configuration: AuthConfiguration

    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }

    func authRequest() -> URLRequest {
        guard var urlComponents = URLComponents(string: configuration.authorizeURL) else {
            fatalError("Failed to create URLComponents")
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]

        guard let url = urlComponents.url else {
            fatalError("Failed to create URL from URLComponents")
        }

        return URLRequest(url: url)
    }

    func code(from navigationAction: WKNavigationAction) -> String? {
        guard
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        else {
            return nil
        }
        return codeItem.value
    }
}
