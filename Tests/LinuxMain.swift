import XCTest

import swiftmonkeyTests

var tests = [XCTestCaseEntry]()
tests += swiftmonkeyTests.allTests()
XCTMain(tests)