//
//  DownpourTests.swift
//  Downpour
//
//  Created by Kyle Fuller on 25/12/2016.
//  Copyright © 2016 Stephen Radford. All rights reserved.
//

import XCTest
import Downpour


class DownpourTests: XCTestCase {
    func testStandardShow1() {
        let downpour = Downpour(string: "Mr.Show.Name.S01E02.Source.Quality.Etc-Group")
        XCTAssertEqual(downpour.title, "Mr Show Name")
        XCTAssertEqual(downpour.season, "01")
        XCTAssertEqual(downpour.episode, "02")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testStandardShow2() {
        let downpour = Downpour(string: "Show.Name.S01E02")
        XCTAssertEqual(downpour.title, "Show Name")
        XCTAssertEqual(downpour.season, "01")
        XCTAssertEqual(downpour.episode, "02")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testStandardShow3() {
        let downpour = Downpour(string: "Show Name - S01E02 - My Ep Name")
        XCTAssertEqual(downpour.title, "Show Name")
        XCTAssertEqual(downpour.season, "01")
        XCTAssertEqual(downpour.episode, "02")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func xtestStandardShow4() {
        let downpour = Downpour(string: "Show.1.0.Name.S01.E03.My.Ep.Name-Group")
        XCTAssertEqual(downpour.title, "Show 1.0 Name")
        XCTAssertEqual(downpour.season, "01")
        XCTAssertEqual(downpour.episode, "03")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testStandardShow5() {
        let downpour = Downpour(string: "Show Name - S06E01 - 2009-12-20 - Ep Name")
        XCTAssertEqual(downpour.title, "Show Name")
        XCTAssertEqual(downpour.season, "06")
        XCTAssertEqual(downpour.episode, "01")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testStandardShow6() {
        let downpour = Downpour(string: "Show Name - S06E01 - -30-")
        XCTAssertEqual(downpour.title, "Show Name")
        XCTAssertEqual(downpour.season, "06")
        XCTAssertEqual(downpour.episode, "01")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testStandardShow7() {
        let downpour = Downpour(string: "Show.Name.S06E01.Other.WEB-DL")
        XCTAssertEqual(downpour.title, "Show Name")
        XCTAssertEqual(downpour.season, "06")
        XCTAssertEqual(downpour.episode, "01")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testStandardShow8() {
        let downpour = Downpour(string: "Show.Name.S06E01 Some-Stuff Here")
        XCTAssertEqual(downpour.title, "Show Name")
        XCTAssertEqual(downpour.season, "06")
        XCTAssertEqual(downpour.episode, "01")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testStandardShow9() {
        let downpour = Downpour(string: "Show.Name-0.2010.S01E02.Source.Quality.Etc-Group")
        XCTAssertEqual(downpour.title, "Show Name-0")  // FIXME
        XCTAssertEqual(downpour.season, "01")
        XCTAssertEqual(downpour.episode, "02")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertEqual(downpour.year, "2010")
    }

    func testStandardShow10() {
        let downpour = Downpour(string: "Show-Name-S06E01-720p")
        XCTAssertEqual(downpour.title, "Show-Name")  // FIXME
        XCTAssertEqual(downpour.season, "06")
        XCTAssertEqual(downpour.episode, "01")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testFOVShow1() {
        let downpour = Downpour(string: "Show_Name.1x02.Source_Quality_Etc-Group")
        XCTAssertEqual(downpour.title, "Show_Name")  // FIXME
        XCTAssertEqual(downpour.season, "1")
        XCTAssertEqual(downpour.episode, "02")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testFOVShow2() {
        let downpour = Downpour(string: "Show Name 1x02")
        XCTAssertEqual(downpour.title, "Show Name")
        XCTAssertEqual(downpour.season, "1")
        XCTAssertEqual(downpour.episode, "02")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testFOVShow3() {
        let downpour = Downpour(string: "Show Name 1x02 x264 Test")
        XCTAssertEqual(downpour.title, "Show Name")
        XCTAssertEqual(downpour.season, "1")
        XCTAssertEqual(downpour.episode, "02")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testFOVShow4() {
        let downpour = Downpour(string: "Show Name - 1x02 - My Ep Name")
        XCTAssertEqual(downpour.title, "Show Name")
        XCTAssertEqual(downpour.season, "1")
        XCTAssertEqual(downpour.episode, "02")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testFOVShow5() {
        let downpour = Downpour(string: "Show Name 1x02 x264 Test")
        XCTAssertEqual(downpour.title, "Show Name")
        XCTAssertEqual(downpour.season, "1")
        XCTAssertEqual(downpour.episode, "02")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }

    func testFOVShow6() {
        let downpour = Downpour(string: "Show Name - 1x02 - My Ep Name")
        XCTAssertEqual(downpour.title, "Show Name")
        XCTAssertEqual(downpour.season, "1")
        XCTAssertEqual(downpour.episode, "02")
        XCTAssertEqual(downpour.type, .some(.tv))
        XCTAssertNil(downpour.year)
    }
}
