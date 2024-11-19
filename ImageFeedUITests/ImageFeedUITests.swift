import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        
        // Шаг 2: Нажатие кнопки "Authenticate"
        let authenticateButton = app.buttons["Authenticate"]
        XCTAssertTrue(authenticateButton.exists, "Кнопка 'Authenticate' не найдена")
        authenticateButton.tap()
        
        // Шаг 3: Проверить загрузку WebView
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5), "WebView не появился")
        
        // Шаг 4: Ввод логина
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5), "Поле для логина не найдено")
        loginTextField.tap()
        loginTextField.typeText("petrosienko.nikita@mail.ru") // Введите ваш e-mail
        
        // Используем кнопку Done для скрытия клавиатуры
        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.exists, "Кнопка 'Done' не найдена")
        doneButton.tap()
        sleep(2) // Задержка для завершения действия
        
        // Ввод пароля
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5), "Поле для пароля не найдено")
        passwordTextField.tap()
        
        // Вставка текста вместо ввода
        UIPasteboard.general.string = "bebra2003"
        passwordTextField.doubleTap() // Открыть контекстное меню
        app.menuItems["Paste"].tap() // Нажать "Вставить"
        sleep(2)
        app.buttons["Done"].tap() // Нажать "Done"
        sleep(1) // Задержка для завершения действия
        
        //        // Скролл вверх для перехода к кнопке "Login"
        //        webView.swipeUp()
        //        sleep(2) // Задержка для завершения действия
        
        // Шаг 6: Нажатие кнопки "Login"
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.exists, "Кнопка 'Login' не найдена")
        loginButton.tap()
        sleep(2)
        // Шаг 7: Дождаться загрузки таблицы
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "Не появилась лента с картинками")
    }
    
    func testFeed() throws {
        sleep(3) // Задержка для загрузки ленты
        
        let table = app.tables["feedTable"]
        let cell = table.cells.firstMatch
        
        table.swipeUp()
        sleep(2)
        
        table.swipeDown()
        sleep(2)
        
        let likeButton = cell.buttons["likeButton"]
        XCTAssertTrue(likeButton.exists, "Кнопка лайка не найдена")
        
        let initialState = likeButton.value as? String
        likeButton.tap()
        sleep(3)
        
        let stateAfterFirstTap = likeButton.value as? String
        XCTAssertNotEqual(initialState, stateAfterFirstTap, "Состояние кнопки не изменилось после первого нажатия")
        
        likeButton.tap()
        sleep(2)
        
        let finalState = likeButton.value as? String
        XCTAssertNotEqual(stateAfterFirstTap, finalState, "Состояние кнопки не изменилось после второго нажатия")
        
        cell.tap()
        sleep(2)
        
        let image = app.scrollViews.images.firstMatch
        XCTAssertTrue(image.exists, "Изображение не найдено в детальном просмотре")
        
        image.pinch(withScale: 3, velocity: 1) // zoom in
        sleep(1)
        image.pinch(withScale: 0.5, velocity: -1) // zoom out
        sleep(1)
        
        app.buttons["backButton"].tap()
        sleep(1)
        
        XCTAssertTrue(table.exists, "Не вернулись к списку изображений")
    }
    
    func testProfile() throws {
        sleep(3) // Задержка для загрузки TabBar
        
        let tabBar = app.tabBars["Tab Bar"]
        let profileButton = tabBar.buttons["profileTab"]
        
        XCTAssertTrue(profileButton.exists, "Кнопка профиля не найдена")
        profileButton.tap()
        sleep(2)
        
        let nameLabel = app.staticTexts["nameLabel"]
        let usernameLabel = app.staticTexts["loginNameLabel"]
        
        XCTAssertTrue(nameLabel.exists, "Имя пользователя не найдено")
        XCTAssertTrue(usernameLabel.exists, "Логин пользователя не найден")
        
        let logoutButton = app.buttons["logoutButton"]
        XCTAssertTrue(logoutButton.exists, "Кнопка выхода не найдена")
        logoutButton.tap()
        sleep(1)
        
        let alert = app.alerts["Пока, пока!"]
        XCTAssertTrue(alert.exists, "Алерт не появился")
        
        let yesButton = alert.buttons["Да"]
        XCTAssertTrue(yesButton.exists, "Кнопка 'Да' не найдена")
        yesButton.tap()
        sleep(1)
        // Проверка возврата к экрану авторизации
        let authenticateButton = app.buttons["Authenticate"]
        XCTAssertTrue(authenticateButton.exists, "Кнопка авторизации не отображается")
    }
}
