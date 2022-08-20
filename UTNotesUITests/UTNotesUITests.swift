//
//  UTNotesUITests.swift
//  UTNotesUITests
//
//  Created by 倪可塑 on 2021/4/20.
//

import XCTest

class UTNotesUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func launchAppAndOpenDemoDocument(darkMode: Bool) throws -> XCUIApplication {
        let app = XCUIApplication()

        setupSnapshot(app)

        let usingEnglish = (deviceLanguage == "en-US")
        let title = usingEnglish ? "Fundamental theorem of calculus" : "微积分基本定理"

        app.launchArguments.append(contentsOf: ["-OPEN_TEST_FILE", title])
        
        if darkMode {
            app.launchArguments.append(contentsOf: ["FORCE_USEING_DARKMODE"])
        }

        app.launch()

        let textView = app.textViews["MainEditor"]
        
        sleep(1)

        textView.tap()
        textView.tap()
        let selectAllItem = app.menuItems["Select All"].exists ? app.menuItems["Select All"] : app.menuItems["全选"]
        let cutItem = app.menuItems["Cut"].exists ? app.menuItems["Cut"] : app.menuItems["剪切"]
        if selectAllItem.exists && cutItem.exists {
            selectAllItem.tap()
            cutItem.tap()
        }

        guard
            let url = Bundle(for: Self.self).url(forResource: title, withExtension: "md"),
            let document = try? String(contentsOf: url, encoding: .utf8)
        else {
            throw NSError()
        }

        textView.typeText(document)

        return app
    }

    func testExample() throws {
        let app = try launchAppAndOpenDemoDocument(darkMode: false)
        
        let textView = app.textViews["MainEditor"]
        textView.tap()
        
        var spaceKey = app.keys["空格"].firstMatch
        if !spaceKey.exists {
            spaceKey = app.keys["空格键"].firstMatch
        }
        if !spaceKey.exists {
            spaceKey = app.keys["space"].firstMatch
        }

        let moreKey = app.keys["more"].firstMatch
        if !spaceKey.exists || !moreKey.exists {
            return
        }
        spaceKey.press(forDuration: 1, thenDragTo: moreKey)

        snapshot("editor")

        app.buttons["FormulaBarButton"].tap()
        app.textViews["FormulaEditor"].tap()

        snapshot("formula")
        app.buttons["FormulaEditorController_DoneButton"].tap()

        app.buttons["PreviewBarButton"].tap()
        snapshot("preview")
    }

    func testDarkmode() throws{
        let app = try launchAppAndOpenDemoDocument(darkMode: true)
        let textView = app.textViews["MainEditor"]
        textView.swipeDown()
        textView.swipeDown()
        app.buttons["PreviewBarButton"].tap()
        snapshot("darkmode_preview")
        
        app.navigationBars.firstMatch.buttons.firstMatch.tap()
        snapshot("darkmode_editor")
    }
}
