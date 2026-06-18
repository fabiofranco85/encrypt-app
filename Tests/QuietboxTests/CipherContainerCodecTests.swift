import XCTest
@testable import Quietbox

final class CipherContainerCodecTests: XCTestCase {
    private func sampleContainer() -> CipherContainer {
        CipherContainer(
            parameters: CryptoParameters(opsLimit: 2, memLimit: 64 * 1024 * 1024),
            salt: Data(repeating: 0xA1, count: CryptoSizes.salt),
            nonce: Data(repeating: 0xB2, count: CryptoSizes.nonce),
            ciphertext: Data(repeating: 0xC3, count: 40)
        )
    }

    func test_encodeDecode_roundTrips() throws {
        let container = sampleContainer()
        let decoded = try CipherContainerCodec.decode(CipherContainerCodec.encode(container))
        XCTAssertEqual(decoded, container)
    }

    func test_headerLayout_hasExpectedLengths() {
        let container = sampleContainer()
        let encoded = CipherContainerCodec.encode(container)
        XCTAssertEqual(CipherContainer.associatedDataLength, 40)
        XCTAssertEqual(CipherContainer.headerLength, 64)
        XCTAssertEqual([UInt8](encoded.prefix(4)), CipherContainer.magic)
        XCTAssertEqual(encoded.count, 64 + 40)
    }

    func test_associatedData_isPrefixOfEncoding() {
        let container = sampleContainer()
        let encoded = CipherContainerCodec.encode(container)
        let aad = CipherContainerCodec.associatedData(
            parameters: container.parameters,
            salt: container.salt
        )
        XCTAssertEqual(aad.count, CipherContainer.associatedDataLength)
        XCTAssertEqual(Data(encoded.prefix(CipherContainer.associatedDataLength)), aad)
    }

    func test_decode_tooShort_throwsMalformed() {
        XCTAssertThrowsError(try CipherContainerCodec.decode(Data([0x00, 0x01]))) {
            XCTAssertEqual($0 as? CryptoError, .malformedArtifact)
        }
    }

    func test_decode_badMagic_throwsMalformed() {
        var encoded = CipherContainerCodec.encode(sampleContainer())
        encoded[0] = 0x00
        XCTAssertThrowsError(try CipherContainerCodec.decode(encoded)) {
            XCTAssertEqual($0 as? CryptoError, .malformedArtifact)
        }
    }

    func test_decode_unsupportedVersion_throws() {
        var encoded = CipherContainerCodec.encode(sampleContainer())
        encoded[4] = 0x99 // version byte
        XCTAssertThrowsError(try CipherContainerCodec.decode(encoded)) {
            XCTAssertEqual($0 as? CryptoError, .unsupportedVersion(0x99))
        }
    }

    func test_decode_unsupportedAlgorithm_throws() {
        var encoded = CipherContainerCodec.encode(sampleContainer())
        encoded[5] = 0x42 // kdfId byte
        XCTAssertThrowsError(try CipherContainerCodec.decode(encoded)) {
            XCTAssertEqual($0 as? CryptoError, .unsupportedAlgorithm)
        }
    }
}
