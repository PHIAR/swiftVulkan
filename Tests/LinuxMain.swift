import XCTest

import swiftVulkanTests

var tests = [XCTestCaseEntry]()
tests += swiftVulkanTests.allTests()
XCTMain(tests)
