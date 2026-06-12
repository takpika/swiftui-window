import XCTest
import SwiftUI
@testable import SwiftUIWindow

final class SwiftUIWindowTests: XCTestCase {
    func testWindowConfigDefaults() {
        let config = WindowConfig(title: "Demo")

        XCTAssertEqual(config.title, "Demo")
        XCTAssertEqual(config.size, CGSize(width: 300, height: 300))
        XCTAssertEqual(config.position, .zero)
        XCTAssertTrue(config.closable)
        XCTAssertTrue(config.minimizable)
        XCTAssertTrue(config.resizable)
        XCTAssertTrue(config.showLabel)
        XCTAssertTrue(config.showWindowBar)
        XCTAssertEqual(config.startPos, .normal)
    }

    func testWindowConfigCanBeCustomized() {
        let config = WindowConfig(
            title: "Inspector",
            size: CGSize(width: 480, height: 320),
            position: CGPoint(x: 24, y: 48),
            closable: false,
            minimizable: false,
            resizable: false,
            showLabel: false,
            showWindowBar: false,
            startPos: .center
        )

        XCTAssertEqual(config.title, "Inspector")
        XCTAssertEqual(config.size, CGSize(width: 480, height: 320))
        XCTAssertEqual(config.position, CGPoint(x: 24, y: 48))
        XCTAssertFalse(config.closable)
        XCTAssertFalse(config.minimizable)
        XCTAssertFalse(config.resizable)
        XCTAssertFalse(config.showLabel)
        XCTAssertFalse(config.showWindowBar)
        XCTAssertEqual(config.startPos, .center)
    }
}
