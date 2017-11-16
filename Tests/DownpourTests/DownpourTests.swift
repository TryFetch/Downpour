//
//  DownpourTests.swift
//  Downpour
//
//  Created by Kyle Fuller on 25/12/2016.
//  Copyright © 2016 Stephen Radford. All rights reserved.
//

import XCTest
@testable import Downpour


class DownpourTests: XCTestCase {

	override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testMovie1() {
        let downpour = Downpour(name: "Movie.Name.2013.1080p.BluRay.H264.AAC.mp4")
        XCTAssertEqual(downpour.title, "Movie Name")
        XCTAssertEqual(downpour.year, "2013")
        XCTAssertNil(downpour.season)
        XCTAssertNil(downpour.episode)
        XCTAssertEqual(downpour.type, .some(.movie))
    }

    func testMovie2() {
        let downpour = Downpour(name: "Movie_Name_2_2017_x264_RARBG.avi")
        XCTAssertEqual(downpour.title, "Movie_Name_2") // FIXME
        XCTAssertEqual(downpour.year, "2017")
        XCTAssertNil(downpour.season)
        XCTAssertNil(downpour.episode)
        XCTAssertEqual(downpour.type, .some(.movie))
    }

    func testStandardShow1() {
        let downpour = Downpour(name: "Mr.Show.Name.S01E02.Source.Quality.Etc-Group")
        XCTAssertEqual(downpour.title, "Mr Show Name")
        XCTAssertEqual(downpour.season, "01")
        XCTAssertEqual(downpour.episode, "02")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testStandardShow2() {
        let downpour = Downpour(name: "Show.Name.S01E02")
        XCTAssertEqual(downpour.title, "Show Name")
        XCTAssertEqual(downpour.season, "01")
        XCTAssertEqual(downpour.episode, "02")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testStandardShow3() {
        let downpour = Downpour(name: "Show Name - S01E02 - My Ep Name")
        XCTAssertEqual(downpour.title, "Show Name")
        XCTAssertEqual(downpour.season, "01")
        XCTAssertEqual(downpour.episode, "02")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testStandardShow4() {
        let downpour = Downpour(name: "Show.2.0.Name.S01.E03.My.Ep.Name-Group")
        XCTAssertEqual(downpour.title, "Show 2.0 Name")
        XCTAssertEqual(downpour.season, "01")
        XCTAssertEqual(downpour.episode, "03")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testStandardShow5() {
        let downpour = Downpour(name: "Show Name - S06E01 - 2009-12-20 - Ep Name")
        XCTAssertEqual(downpour.title, "Show Name")
        XCTAssertEqual(downpour.season, "06")
        XCTAssertEqual(downpour.episode, "01")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testStandardShow6() {
        let downpour = Downpour(name: "Show Name - S06E01 - -30-")
        XCTAssertEqual(downpour.title, "Show Name")
        XCTAssertEqual(downpour.season, "06")
        XCTAssertEqual(downpour.episode, "01")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testStandardShow7() {
        let downpour = Downpour(name: "Show.Name.S06E01.Other.WEB-DL")
        XCTAssertEqual(downpour.title, "Show Name")
        XCTAssertEqual(downpour.season, "06")
        XCTAssertEqual(downpour.episode, "01")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testStandardShow8() {
        let downpour = Downpour(name: "Show.Name.S06E01 Some-Stuff Here")
        XCTAssertEqual(downpour.title, "Show Name")
        XCTAssertEqual(downpour.season, "06")
        XCTAssertEqual(downpour.episode, "01")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testStandardShow9() {
        let downpour = Downpour(name: "Show.Name-0.2010.S01E02.Source.Quality.Etc-Group")
        XCTAssertEqual(downpour.title, "Show Name-0")  // FIXME
        XCTAssertEqual(downpour.season, "01")
        XCTAssertEqual(downpour.episode, "02")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertEqual(downpour.year, "2010")
    }

    func testStandardShow10() {
        let downpour = Downpour(name: "Show-Name-S06E01-720p")
        XCTAssertEqual(downpour.title, "Show-Name")  // FIXME
        XCTAssertEqual(downpour.season, "06")
        XCTAssertEqual(downpour.episode, "01")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testFOVShow1() {
        let downpour = Downpour(name: "Show_Name.1x02.Source_Quality_Etc-Group")
        XCTAssertEqual(downpour.title, "Show_Name")  // FIXME
        XCTAssertEqual(downpour.season, "1")
        XCTAssertEqual(downpour.episode, "02")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testFOVShow2() {
        let downpour = Downpour(name: "Show Name 1x02")
        XCTAssertEqual(downpour.title, "Show Name")
        XCTAssertEqual(downpour.season, "1")
        XCTAssertEqual(downpour.episode, "02")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testFOVShow3() {
        let downpour = Downpour(name: "Show Name 1x02 x264 Test")
        XCTAssertEqual(downpour.title, "Show Name")
        XCTAssertEqual(downpour.season, "1")
        XCTAssertEqual(downpour.episode, "02")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testFOVShow4() {
        let downpour = Downpour(name: "Show Name - 1x02 - My Ep Name")
        XCTAssertEqual(downpour.title, "Show Name")
        XCTAssertEqual(downpour.season, "1")
        XCTAssertEqual(downpour.episode, "02")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testFOVShow5() {
        let downpour = Downpour(name: "Show Name 1x02 x264 Test")
        XCTAssertEqual(downpour.title, "Show Name")
        XCTAssertEqual(downpour.season, "1")
        XCTAssertEqual(downpour.episode, "02")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testFOVShow6() {
        let downpour = Downpour(name: "Show Name - 1x02 - My Ep Name")
        XCTAssertEqual(downpour.title, "Show Name")
        XCTAssertEqual(downpour.season, "1")
        XCTAssertEqual(downpour.episode, "02")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }
}

#if os(Linux)
extension DownpourTests {
    static var allTests: [(String, (DownpourTests) -> () throws -> Void)] {
        return [
            ("testMovie1", testMovie1),
            ("testMovie2", testMovie2),
            ("testStandardShow1", testStandardShow1),
            ("testStandardShow2", testStandardShow2),
            ("testStandardShow3", testStandardShow3),
            ("testStandardShow4", testStandardShow4),
            ("testStandardShow5", testStandardShow5),
            ("testStandardShow6", testStandardShow6),
            ("testStandardShow7", testStandardShow7),
            ("testStandardShow8", testStandardShow8),
            ("testStandardShow9", testStandardShow9),
            ("testStandardShow10", testStandardShow10),
            ("testFOVShow1", testFOVShow1),
            ("testFOVShow2", testFOVShow2),
            ("testFOVShow3", testFOVShow3),
            ("testFOVShow4", testFOVShow4),
            ("testFOVShow5", testFOVShow5),
            ("testFOVShow6", testFOVShow6)
        ]
    }
}
#endif
