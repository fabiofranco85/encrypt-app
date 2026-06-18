import XCTest
@testable import Cipherbox

final class ByteCodecTests: XCTestCase {
    func test_writeThenRead_roundTripsIntegers() throws {
        var writer = ByteWriter()
        writer.writeUInt8(0xAB)
        writer.writeUInt16(0x1234)
        writer.writeUInt64(0x0102030405060708)
        writer.writeBytes(Data([0xDE, 0xAD]))

        var reader = ByteReader(writer.data)
        XCTAssertEqual(try reader.readUInt8(), 0xAB)
        XCTAssertEqual(try reader.readUInt16(), 0x1234)
        XCTAssertEqual(try reader.readUInt64(), 0x0102030405060708)
        XCTAssertEqual(try reader.readBytes(2), Data([0xDE, 0xAD]))
    }

    func test_readBeyondEnd_throwsMalformed() {
        var reader = ByteReader(Data([0x01]))
        XCTAssertThrowsError(try reader.readUInt16()) { error in
            XCTAssertEqual(error as? CryptoError, .malformedArtifact)
        }
    }

    func test_readRemaining_returnsRest() throws {
        var reader = ByteReader(Data([1, 2, 3, 4]))
        _ = try reader.readUInt8()
        XCTAssertEqual(reader.readRemaining(), Data([2, 3, 4]))
        XCTAssertEqual(reader.remainingCount, 0)
    }
}
