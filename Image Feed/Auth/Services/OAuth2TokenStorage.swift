import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let tokenKey = "accessToken" // Ключ для хранения токена в Keychain
    
    // Свойство для получения и установки токена
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey) // Получение токена из Keychain
        }
        set {
            if let newToken = newValue {
                KeychainWrapper.standard.set(newToken, forKey: tokenKey) // Сохранение токена в Keychain
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey) // Удаление токена, если значение nil
            }
        }
    }
    
    // Метод для очистки токена
    func clearToken() {
        KeychainWrapper.standard.removeObject(forKey: tokenKey)
    }
}
