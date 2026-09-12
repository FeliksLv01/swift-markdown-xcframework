import Markdown
import XCTest

final class DoubleTildeTests: XCTestCase {
    func testSingleTildeIsPlainText() {
        let document = Document(parsing: "~text~")
        XCTAssertNil(document.child(through: 0, 0) as? Strikethrough)
        XCTAssertEqual(document.format(), "~text~")
    }

    func testDoubleTildeIsStrikethrough() {
        let document = Document(parsing: "~~text~~")
        XCTAssertNotNil(document.child(through: 0, 0) as? Strikethrough)
    }
}
