func add(_ num1: Int,_ num2: Int) -> Int {
    return num1 + num2
}

import XCTest

class AddingTest: XCTestCase {
    func testAdd() {
        let result = MovieQuizTests.add(4, 7)
        XCTAssertEqual(result, 11)
    }
}

