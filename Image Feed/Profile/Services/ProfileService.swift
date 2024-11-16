import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private(set) var profile: Profile?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
                    print(json)
                }
                
                let profileResult = try JSONDecoder().decode(ProfileResult.self, from: data)
                let profile = Profile(from: profileResult)
                self.profile = profile
                completion(.success(profile))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func loadProfile(completion: @escaping () -> Void) {
        guard profile == nil else {
            completion()
            return
        }
        
        let token = OAuth2TokenStorage().token ?? ""
        fetchProfile(token) { [weak self] result in
            switch result {
            case .success(let profile):
                self?.profile = profile
                completion()
            case .failure(let error):
                print("Error loading profile: \(error)")
                completion()
            }
        }
    }
    
    func clearData() {
        profile = nil
        print("ProfileService: Данные профиля очищены")
    }
}

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(from profileResult: ProfileResult) {
        self.username = profileResult.username
        self.name = "\(profileResult.firstName ?? "") \(profileResult.lastName ?? "")".trimmingCharacters(in: .whitespaces)
        self.loginName = "@\(profileResult.username)"
        self.bio = profileResult.bio
        print("[Profile]: Initialized - name: \(name), loginName: \(loginName), bio: \(bio ?? "No bio")")
    }
}
