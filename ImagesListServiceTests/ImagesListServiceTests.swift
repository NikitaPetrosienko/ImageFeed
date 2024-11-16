@testable import Image_Feed
import XCTest

final class ImagesListServiceTests: XCTestCase {
    func testFetchPhotos() {
        // Инициализируем сервис для теста
        let service = ImagesListService()
        
        // Создаем ожидание для нотификации об изменениях
        let expectation = self.expectation(description: "Wait for Notification")
        
        // Добавляем наблюдатель за уведомлением о получении новых данных
        var notificationReceived = false
        let observer = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            if !notificationReceived {
                notificationReceived = true
                expectation.fulfill()
            }
        }
        
        // Запрашиваем следующую страницу фотографий
        service.fetchPhotosNextPage()
        
        // Ждем, пока уведомление будет отправлено
        wait(for: [expectation], timeout: 10)
        
        // Проверяем, что было загружено ровно 10 фотографий
        XCTAssertEqual(service.photos.count, 10, "Должно быть загружено 10 фотографий")
        
        // Удаляем наблюдателя
        NotificationCenter.default.removeObserver(observer)
    }
}
