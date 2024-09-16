import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication! //эта переменная символизирует приложение, которое мы тестируем

    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false

    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app.terminate()
        app = nil
    }
    
    func testNoButtonIndexLabel() {
        let indexLabel = app.staticTexts["Index"]
        
        app.buttons["No"].tap()
        let newIndexLabel = app.staticTexts["Index"]
        XCTAssertTrue(newIndexLabel.waitForExistence(timeout: 5))
  
        XCTAssertEqual(newIndexLabel.label, "2/10")
    }
    
    func testYesButton()  {
        let firstPoster = app.images["Poster"]  // Находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation // создаётся скриншот
        
        app.buttons["No"].tap() // Находим кнопку "Да" и нажимаем её
        let secondPoster = app.images["Poster"] // Ещё раз находим постер
        XCTAssertTrue(secondPoster.waitForExistence(timeout: 5))
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        XCTAssertNotEqual(firstPosterData, secondPosterData) //Происходит сравнение скриншотов
    }
   
}
