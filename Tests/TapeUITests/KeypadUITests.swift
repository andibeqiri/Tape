import XCTest

final class KeypadUITests: XCTestCase {
    func testNumberTapsBuildExpression() {
        let app = XCUIApplication()
        app.launch()

        app.buttons["1"].tap()
        app.buttons["2"].tap()
        app.buttons["+"].tap()
        app.buttons["3"].tap()

        XCTAssertEqual(app.descendants(matching: .any)["expression"].label, "12+3")
    }

    func testConsecutiveOperatorsAreIgnored() {
        let app = XCUIApplication()
        app.launch()

        app.buttons["2"].tap()
        app.buttons["+"].tap()
        app.buttons["+"].tap()
        app.buttons["−"].tap()
        app.buttons["2"].tap()

        XCTAssertEqual(app.descendants(matching: .any)["expression"].label, "2+2")
    }

    func testButtonCornerIsTappable() {
        let app = XCUIApplication()
        app.launch()

        app.buttons["7"]
            .coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1))
            .tap()

        XCTAssertEqual(app.descendants(matching: .any)["expression"].label, "7")
    }

    func testHistoryOnlyAppearsFromHistoryButton() {
        let app = XCUIApplication()
        app.launch()

        app.buttons["2"].tap()
        app.buttons["+"].tap()
        app.buttons["2"].tap()
        app.buttons["="].tap()

        let history = app.descendants(matching: .any)["historyList"]
        XCTAssertFalse(history.exists)

        app.buttons["History"].tap()
        XCTAssertTrue(history.waitForExistence(timeout: 1))

        app.navigationBars["History"].buttons["History"].tap()
        XCTAssertTrue(history.waitForNonExistence(timeout: 1))
    }
}
