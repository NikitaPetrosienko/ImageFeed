import UIKit

enum Constants {
    static let accessKey = "DopOPlaJD4juwUpzVqw6wI5BmAd3ZSF9SRrSNlWiSfc"
    static let secretKey = "N3_P_vDmxZYOVfapqC4qNmKAcsTtuoYE0VIU_C-qi3o"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    
    
    static let accessScope = "public+read_user+write_likes"
    
    static let tokenURL = URL(string: "https://unsplash.com/oauth/token")
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Невозможно создать URL из строки.")
        }
        return url
    }()
}

