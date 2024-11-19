import Foundation

struct AuthConfiguration {
    let authorizeURL: String
    let accessKey: String
    let redirectURI: String
    let accessScope: String

    static let standard = AuthConfiguration(
        authorizeURL: "https://unsplash.com/oauth/authorize",
        accessKey: "DopOPlaJD4juwUpzVqw6wI5BmAd3ZSF9SRrSNlWiSfc",
        redirectURI: "urn:ietf:wg:oauth:2.0:oob",
        accessScope: "public+read_user+write_likes"
    )
}
