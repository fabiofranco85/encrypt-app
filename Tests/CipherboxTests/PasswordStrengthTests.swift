import XCTest
@testable import Cipherbox

final class PasswordStrengthTests: XCTestCase {
    func test_empty_isEmptyLevelWithZeroScore() {
        let strength = PasswordStrength.evaluate("")
        XCTAssertEqual(strength.level, .empty)
        XCTAssertEqual(strength.score, 0)
        XCTAssertEqual(strength.estimatedBits, 0)
    }

    func test_shortSimple_isWeak() {
        XCTAssertEqual(PasswordStrength.evaluate("abc").level, .weak)
    }

    func test_commonWord_isFair() {
        XCTAssertEqual(PasswordStrength.evaluate("password").level, .fair)
    }

    func test_mixedMedium_isGood() {
        XCTAssertEqual(PasswordStrength.evaluate("Sup3rSecret!").level, .good)
    }

    func test_longMixed_isStrong() {
        XCTAssertEqual(PasswordStrength.evaluate("Sup3r-Secret-Passphrase!-2026").level, .strong)
    }

    func test_score_isClampedToUnitInterval() {
        let strength = PasswordStrength.evaluate(String(repeating: "Aa1!", count: 40))
        XCTAssertLessThanOrEqual(strength.score, 1.0)
        XCTAssertGreaterThan(strength.score, 0.0)
    }

    func test_longerPassword_neverHasFewerBits() {
        let shorter = PasswordStrength.evaluate("Abcdef1!")
        let longer = PasswordStrength.evaluate("Abcdef1!Abcdef1!")
        XCTAssertGreaterThanOrEqual(longer.estimatedBits, shorter.estimatedBits)
    }

    func test_lowVariety_scoresLowerThanHighVariety() {
        let repeated = PasswordStrength.evaluate("aaaaaaaaaaaa")
        let varied = PasswordStrength.evaluate("abcdefghijkl")
        XCTAssertLessThan(repeated.estimatedBits, varied.estimatedBits)
    }
}
