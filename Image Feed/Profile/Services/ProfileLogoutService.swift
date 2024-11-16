import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    func logout(completion: @escaping () -> Void) { // Добавлено completion
        clearToken()
        clearServicesData() // Очищаем данные всех сервисов
        cleanCookies {
            DispatchQueue.main.async {
                completion()  // Вызов completion после очистки
            }
        }
    }
    
    private func clearToken() {
        OAuth2TokenStorage().clearToken()
    }
    
    private func clearServicesData() {
        ProfileService.shared.clearData()  // Очищаем данные профиля
        ProfileImageService.shared.clearData()  // Очищаем данные аватара профиля
        ImagesListService.shared.clearData()  // Очищаем список изображений
    }
    
    private func cleanCookies(completion: @escaping () -> Void) {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            let dispatchGroup = DispatchGroup()
            records.forEach { record in
                dispatchGroup.enter()
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record]) {
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {
                completion()
            }
        }
    }
}
