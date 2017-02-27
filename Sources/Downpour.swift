//
//  Downpour.swift
//  Downpour
//
//  Created by Stephen Radford on 18/05/2016.
//  Copyright © 2016 Stephen Radford. All rights reserved.
//

import Foundation
import PathKit

open class Downpour: CustomStringConvertible {

    /// The raw string that has not yet been parsed by Downpour.
    var rawString: String

    /// The full path to the file
    var fullPath: Path

    /// The metadata for the file (useful generally only for music files)
    lazy var metadata: Metadata? = {
        return try? Metadata(self.fullPath)
    }()

    /// The patterns that will be used to fetch various pieces of information from the rawString.
    let patterns: [String: String] = [
        "season": "[Ss]?\\d{1,2}[EexX]\\d{1,2}",
        "altSeason": "[Ss]eason \\d{1,2} [Ee]pisode \\d{1,2}",
        "altSeasonSingle": "[Ss]eason \\d{1,2}",
        "altEpisodeSingle": "[Ee]pisode \\d{1,2}",
        "altSeason2": "[ .-]\\d{3}[ .-]",
        "year": "[(\\. \\[](19|20)\\d{2}[\\] \\.)]"
    ]

    /// Both the season and the episode together.
    lazy open var seasonEpisode: String? = {
        if let match = self.rawString.range(of: self.patterns["season"]!, options: .regularExpression) {
            return self.rawString[match]
        } else if let match = self.rawString.range(of: self.patterns["altSeason"]!, options: .regularExpression) {
            return self.rawString[match]
        } else if let match = self.rawString.range(of: self.patterns["altSeason2"]!, options: .regularExpression) {
            return self.rawString[match].cleanedString
        }

        return nil
    }()

    /// The TV Season - e.g. 02
    lazy open var season: String? = {
        if let both = self.seasonEpisode {

            if both.characters.count > 6 {

                let match = self.rawString.range(of: self.patterns["altSeasonSingle"]!, options: .regularExpression)
                let string = self.rawString[match!]

                let startIndex = string.startIndex
                let endIndex = string.characters.index(string.startIndex, offsetBy: 6)

                return string.replacingCharacters(in: startIndex..<endIndex, with: "").cleanedString

            } else if both.characters.count == 3 {

                return both[both.startIndex...both.startIndex].cleanedString

            }

            let charset = CharacterSet(charactersIn: "eExX")
            let pieces = both.components(separatedBy: charset)

            let chars = pieces[0].characters
            if chars.count == 3 {
                let startIndex = chars.index(pieces[0].startIndex, offsetBy: 1)
                let endIndex = chars.index(pieces[0].startIndex, offsetBy: 2)
                return pieces[0][startIndex...endIndex].cleanedString
            }

            return pieces[0].cleanedString

        }
        return nil
    }()

    /// The TV Episode - e.g. 22
    lazy open var episode: String? = {
        if let both = self.seasonEpisode {
            let chars = both.characters
            if chars.count > 6 {
                let match = self.rawString.range(of: self.patterns["altEpisodeSingle"]!, options: .regularExpression)
                let string = self.rawString[match!]

                let startIndex = string.startIndex
                let endIndex = string.characters.index(string.startIndex, offsetBy: 6)

                return string.replacingCharacters(in: startIndex..<endIndex, with: "").cleanedString

            } else if chars.count == 3 {
                let startIndex = chars.index(both.startIndex, offsetBy: 1)
                let endIndex = chars.index(both.startIndex, offsetBy: 2)
                return both[startIndex...endIndex].cleanedString

            }

            let charset = CharacterSet(charactersIn: "eExX")
            let pieces = both.components(separatedBy: charset)

            return pieces[1].cleanedString
        }
        return nil
    }()

    private let musicExtensions: [String] = [
                                             "aa", "aac", "aax", "act", "aiff",
                                             "alac", "amr", "ape", "au", "awb",
                                             "dct", "dss", "dvf", "flac", "gsm",
                                             "iklax", "ivs", "m4a", "m4b", "m4p",
                                             "mmf", "mp3", "mpc", "msv", "oga",
                                             "mogg", "opus", "ra", "sln", "tta",
                                             "vox", "wav", "wma", "wv"
                                            ]
    private let videoExtensions: [String] = [
                                             "mkv", "flv", "vob", "ogv", "drc",
                                             "gifv", "mng", "avi", "mov", "qt",
                                             "wmv", "yuv", "rmvb", "asf", "amv",
                                             "mp4", "m4p", "m4v", "mpg", "mp2",
                                             "mpeg", "mpe", "mpv", "svi", "3g2",
                                             "mx4", "roq", "nsv", "f4v", "f4p",
                                             "f4a", "f4b"
                                           ]

    /// Is it TV, Movie, or Audio?
    lazy open var type: DownpourType = {
        let ext = self.fullPath.extension ?? ""
        if self.videoExtensions.contains(ext) {
            if self.season != nil {
                return .tv
            }
            return .movie
        } else if self.musicExtensions.contains(ext) {
            return .music
        } else {
            guard let format = self.metadata?.format else { return .unknown }
            let components = format.lowercased().components(separatedBy: "/")
            if components.contains("video") {
                return .movie
            } else if components.contains("audio") {
                return .music
            }
            return .unknown
        }
    }()

    /// Year of release
    lazy open var year: String? = {
        if [DownpourType.movie, DownpourType.tv].contains(self.type) {
            if let match = self.rawString.range(of: self.patterns["year"]!, options: .regularExpression) {
                let found = self.rawString[match]
                return found.cleanedString
            }
        } else if self.type == .music, let date = self.metadata?.creationDate {
            let year = NSCalendar.current.component(.year, from: date)
            return String(year)
        }
        return nil
    }()

    /// Title of the TV Show or Movie
    lazy open var title: String = {
        if self.type == .tv {
            // Check if there is actually a title before the episode string
            if let se = self.rawString.range(of: self.seasonEpisode!), se.lowerBound != self.rawString.startIndex {
                let endIndex = self.rawString.index(se.lowerBound, offsetBy: -1)
                var string = self.rawString[self.rawString.startIndex...endIndex].cleanedString
                if self.year != nil {
                    let endIndex = self.rawString.index(self.rawString.range(of: self.year!)!.lowerBound, offsetBy: -1)
                    string = self.rawString[self.rawString.startIndex...endIndex].cleanedString
                }
                return string
            }

            return self.rawString.cleanedString

        } else if self.type == .movie && self.year != nil {
            let endIndex = self.rawString.index(self.rawString.range(of: self.year!)!.lowerBound, offsetBy: -1)
            return self.rawString[self.rawString.startIndex...endIndex].cleanedString
        } else if self.type == .music, let title = self.metadata?.title {
            return title
        }

        return self.rawString.cleanedString
    }()

    lazy var artist: String? = {
        guard self.type == .music else { return nil }
        return self.metadata?.artist
    }()

    lazy var album: String? = {
        guard self.type == .music else { return nil }
        return self.metadata?.album
    }()

    // MARK: - CustomStringConvertible

    open var description: String {
        if type == .tv {
            return "Title: \(title); Episode: \(episode); Season: \(season); Year: \(year)"
        } else if type == .movie {
            return "Title: \(title); Year: \(year)"
        } else if type == .music {
            return "Title: \(title); Artist: \(artist); Album: \(album); ReleaseDate: \(year)"
        } else {
            return "Unkown media type. Cannot describe."
        }
    }

    // MARK: - Initializers

    public init(name: String, path: Path) {
        rawString = name
        fullPath = path.isFile ? path : path + name
    }

    public init(fullPath: Path) {
        self.fullPath = fullPath
        self.rawString = fullPath.lastComponent
    }

}
