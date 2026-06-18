import XCTest
@testable import Quietbox

final class ArtifactTests: XCTestCase {
    func test_textArtifact_isCopyOnly() {
        let artifact = Artifact(content: .text("secret"))
        XCTAssertTrue(artifact.isText)
        XCTAssertEqual(artifact.allowedActions, [.copy])
    }

    func test_fileArtifact_allowsCopyShareSave() {
        let artifact = Artifact(content: .file(data: Data([1, 2, 3]), filename: "a.bin"))
        XCTAssertFalse(artifact.isText)
        XCTAssertEqual(artifact.allowedActions, [.copy, .share, .save])
    }
}
