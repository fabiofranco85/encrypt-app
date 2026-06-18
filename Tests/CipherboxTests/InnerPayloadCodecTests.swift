import XCTest
@testable import Cipherbox

final class InnerPayloadCodecTests: XCTestCase {
    func test_textPayload_roundTrips() throws {
        let payload = InnerPayload.text("hello, world 🌍")
        let decoded = try InnerPayloadCodec.decode(InnerPayloadCodec.encode(payload))
        XCTAssertEqual(decoded.kind, .text)
        XCTAssertEqual(decoded.filename, "")
        XCTAssertEqual(String(decoding: decoded.data, as: UTF8.self), "hello, world 🌍")
    }

    func test_filePayload_roundTripsUnicodeName() throws {
        let bytes = Data((0..<256).map { UInt8($0) })
        let payload = InnerPayload.file(named: "café — résumé.pdf", data: bytes)
        let decoded = try InnerPayloadCodec.decode(InnerPayloadCodec.encode(payload))
        XCTAssertEqual(decoded.kind, .file)
        XCTAssertEqual(decoded.filename, "café — résumé.pdf")
        XCTAssertEqual(decoded.data, bytes)
    }

    func test_emptyData_roundTrips() throws {
        let payload = InnerPayload.file(named: "empty.bin", data: Data())
        let decoded = try InnerPayloadCodec.decode(InnerPayloadCodec.encode(payload))
        XCTAssertEqual(decoded.data, Data())
        XCTAssertEqual(decoded.filename, "empty.bin")
    }

    func test_decode_empty_throwsMalformed() {
        XCTAssertThrowsError(try InnerPayloadCodec.decode(Data())) {
            XCTAssertEqual($0 as? CryptoError, .malformedArtifact)
        }
    }

    func test_decode_unknownKind_throwsMalformed() {
        // kind=0x09, filenameLength=0
        XCTAssertThrowsError(try InnerPayloadCodec.decode(Data([0x09, 0x00, 0x00]))) {
            XCTAssertEqual($0 as? CryptoError, .malformedArtifact)
        }
    }
}
