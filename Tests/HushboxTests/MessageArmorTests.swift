import XCTest
@testable import Hushbox

final class MessageArmorTests: XCTestCase {
    private let sample = Data((0..<200).map { UInt8(truncatingIfNeeded: $0) })

    func test_armorDearmor_roundTrips() throws {
        let armored = MessageArmor.armor(sample)
        XCTAssertTrue(armored.hasPrefix(MessageArmor.header))
        XCTAssertTrue(armored.hasSuffix(MessageArmor.footer))
        XCTAssertEqual(try MessageArmor.dearmor(armored), sample)
    }

    func test_dearmor_toleratesExtraWhitespace() throws {
        let armored = "\n\n  " + MessageArmor.armor(sample) + "  \n\t"
        XCTAssertEqual(try MessageArmor.dearmor(armored), sample)
    }

    func test_dearmor_acceptsBareBase64() throws {
        let bare = sample.base64EncodedString()
        XCTAssertEqual(try MessageArmor.dearmor(bare), sample)
    }

    func test_dearmor_garbage_throwsMalformed() {
        XCTAssertThrowsError(try MessageArmor.dearmor("not base64 @@@@")) {
            XCTAssertEqual($0 as? CryptoError, .malformedArtifact)
        }
    }

    func test_dearmor_empty_throwsMalformed() {
        XCTAssertThrowsError(try MessageArmor.dearmor("   \n  ")) {
            XCTAssertEqual($0 as? CryptoError, .malformedArtifact)
        }
    }
}
