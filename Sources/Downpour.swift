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

    /// The metadata for the file (generally only useful for music files)
    lazy var metadata: Metadata? = {
        return try? Metadata(self.fullPath)
    }()

    /// The patterns that will be used to fetch various pieces of information from the rawString.
    let patterns: [String: String] = [
        "pretty": "S\\d{1,2}[\\-\\.\\s_]?E\\d{1,2}",
        "tricky": "[^\\d]\\d{1,2}[X\\-\\.\\s_]\\d{1,2}[^\\d]?",
        "combined": "(?:S)?)\\d{1,2}[EX\\-\\.\\s_]\\d{1,2}[^\\d]?",
        "altSeason": "Season \\d{1,2} Episode \\d{1,2}",
        "altSeasonSingle": "Season \\d{1,2}",
        "altEpisodeSingle": "Episode \\d{1,2}",
        "altSeason2": "[\\s_\\.\\-\\[]\\d{3}[\\s_\\.\\-\\]]",
        "year": "[\\(?:\\.\\s_\\[](?:19|20)\\d{2}[\\]\\s_\\.\\)]"
    ]

    /// Both the season and the episode together.
    lazy open var seasonEpisode: String? = {
        if let match = self.rawString.range(of: self.patterns["pretty"]!, options: [.regularExpression, .caseInsensitive]) {
            return self.rawString[match]
        } else if var match = self.rawString.range(of: self.patterns["tricky"]!, options: [.regularExpression, .caseInsensitive]) {
            match = self.rawString.index(after: match.lowerBound)..<match.upperBound
            return self.rawString[match]
        } else if var match = self.rawString.range(of: self.patterns["combined"]!, options: [.regularExpression, .caseInsensitive]) {
            match = match.lowerBound..<match.upperBound
            return self.rawString[match]
        } else if let match = self.rawString.range(of: self.patterns["altSeason"]!, options: [.regularExpression, .caseInsensitive]) {
            return self.rawString[match]
        } else if let match = self.rawString.range(of: self.patterns["altSeason2"]!, options: [.regularExpression, .caseInsensitive]) {
            let str = self.rawString[match].cleanedString
            guard ["264", "720"].contains(str[1...3]) else { return str }
        }

        return nil
    }()

    /// The TV Season - e.g. 02
    lazy open var season: String? = {
        if let both = self.seasonEpisode?.cleanedString {
            guard both.characters.count <= 7 else {
                let match = self.rawString.range(of: self.patterns["altSeasonSingle"]!, options: [.regularExpression, .caseInsensitive])
                let string = self.rawString[match!]

                let startIndex = string.startIndex
                let endIndex = string.characters.index(string.startIndex, offsetBy: 6)

                return string.replacingCharacters(in: startIndex..<endIndex, with: "").cleanedString
            }

            guard both.characters.count != 3 else {
                return both[both.startIndex...both.startIndex].cleanedString
            }

            let charset = CharacterSet(charactersIn: "eExX-._")
            let pieces = both.components(separatedBy: charset)

            let chars = pieces[0].characters
            guard chars.count <= 2 && chars.count >= 1 else {
                let startIndex = pieces[0].index(after: pieces[0].startIndex)
                return pieces[0][startIndex..<pieces[0].endIndex].cleanedString
            }

            return pieces[0].cleanedString
        }
        return nil
    }()

    /// The TV Episode - e.g. 22
    lazy open var episode: String? = {
        if let both = self.seasonEpisode?.cleanedString {
            let chars = both.characters

            guard chars.count <= 7 else {
                let match = self.rawString.range(of: self.patterns["altEpisodeSingle"]!, options: [.regularExpression, .caseInsensitive])
                let string = self.rawString[match!]

                let startIndex = string.startIndex
                let endIndex = string.characters.index(string.startIndex, offsetBy: 6)

                return string.replacingCharacters(in: startIndex..<endIndex, with: "").cleanedString
            }
            guard chars.count != 3 else {
                let startIndex = chars.index(both.startIndex, offsetBy: 1)
                let endIndex = chars.index(both.startIndex, offsetBy: 2)
                return both[startIndex...endIndex].cleanedString
            }

            let charset = CharacterSet(charactersIn: "eExX-._")
            let pieces = both.components(separatedBy: charset)

            return pieces[1].cleanedString
        }
        return nil
    }()

    /// Guarenteed extensions for music files (according to Wikipedia)
    private let musicExtensions: [String] = [
                                             "aa", "aac", "aax", "act", "aiff",
                                             "alac", "amr", "ape", "au", "awb",
                                             "dct", "dss", "dvf", "flac", "gsm",
                                             "iklax", "ivs", "m4a", "m4b", "m4p",
                                             "mmf", "mp3", "mpc", "msv", "oga",
                                             "mogg", "opus", "ra", "sln", "tta",
                                             "vox", "wav", "wma", "wv"
                                            ]
    /// Guarneteed extensions for video files (according to Wikipedia)
    private let videoExtensions: [String] = [
                                             "mkv", "flv", "vob", "ogv", "drc",
                                             "gifv", "mng", "avi", "mov", "qt",
                                             "wmv", "yuv", "rmvb", "asf", "amv",
                                             "mp4", "m4p", "m4v", "mpg", "mp2",
                                             "mpeg", "mpe", "mpv", "svi", "3g2",
                                             "mx4", "roq", "nsv", "f4v", "f4p",
                                             "f4a", "f4b"
                                            ]

    /// Guarenteed extensions for subtitle files
    private let subtitleExtensions: [String] = [
                                                "srt", "smi", "ssa", "ass", "vtt"
                                               ]

    /// Is it TV, Movie, or Music?
    lazy open var type: DownpourType = {
        if self.fullPath.string != self.rawString, let ext = self.fullPath.extension?.lowercased() {
            // Test to see if the extension is a video file extension (treat subtitles like video files too)
            if self.videoExtensions.contains(ext) || self.subtitleExtensions.contains(ext) {
                // If we got a season name from the title, then it's a TV show
                if self.season != nil && Int(self.episode ?? "64") ?? 64 < 64 {
                    return .tv
                }
                // Otherwise, it's a movie
                return .movie
            // If the extension is an audio file extension
            } else if self.musicExtensions.contains(ext) {
                // Then return that this is a music file
                return .music
            // If we couldn't identify the format from the file extension, try and use the metadata
            } else {
                // Try and get the format metadata from the file, else return unkown DownpourType
                guard let format = self.metadata?.format else { return .unknown }
                #if os(Linux)
                // This is a MIME Type, so split on the slash and check if the components contains the type
                let components = format.lowercased().components(separatedBy: "/")
                if components.contains("video") {
                    if self.season != nil {
                        return .tv
                    }
                    return .movie
                } else if components.contains("audio") {
                    return .music
                }
                #else
                // I don't know what the format value is for AVAssets, so just print it for now
                print(format)
                #endif
    
                // Returns unkown if the format is neither video nor audio
                return .unknown
            }
        } else {
            if self.season != nil && Int(self.episode ?? "50") ?? 50 < 50 {
                return .tv
            }
            return .movie
        }
    }()

    /// Year of release
    lazy open var year: String? = {
        if [.movie, .tv].contains(self.type) {
            if let match = self.rawString.range(of: self.patterns["year"]!, options: [.regularExpression, .caseInsensitive]) {
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
        var title: String?
        if self.type == .tv {
            // Check if there is actually a title before the episode string
            if let se = self.rawString.range(of: self.seasonEpisode!), se.lowerBound != self.rawString.startIndex {
                let endIndex = self.rawString.index(se.lowerBound, offsetBy: -1)
                var string = self.rawString[self.rawString.startIndex...endIndex]
                if self.year != nil {
                    let endIndex = self.rawString.index(self.rawString.range(of: self.year!)!.lowerBound, offsetBy: -1)
                    string = self.rawString[self.rawString.startIndex...endIndex]
                }
                title = string
            }
        } else if self.type == .movie && self.year != nil {
            let endIndex = self.rawString.index(self.rawString.range(of: self.year!)!.lowerBound, offsetBy: -1)
            title = self.rawString[self.rawString.startIndex...endIndex]
        } else if self.type == .music {
            title = self.metadata?.title
        }

        if let t = title {
            var clean = t.cleanedString
            // Check to see if anything like a 2.0 got cleaned in the name
            if let uncleanMatch = t.range(of: "\\d+\\.\\d+", options: .regularExpression),
               let tooCleanMatch = clean.range(of: "\\d+ \\d+", options: .regularExpression),
               uncleanMatch == tooCleanMatch {
                let replacement = clean[tooCleanMatch].replacingOccurrences(of: " ", with: ".")
                clean = clean.replacingOccurrences(of: clean[tooCleanMatch], with: replacement)
            }
            return clean
        } else {
            return self.rawString.cleanedString
        }
    }()

    /// Artist of the song/track. Returns nil if the type is not .music
    lazy open var artist: String? = {
        guard self.type == .music else { return nil }
        return self.metadata?.artist
    }()

    /// Album of the song/track. Returns nil if the type is not .music
    lazy open var album: String? = {
        guard self.type == .music else { return nil }
        return self.metadata?.album
    }()

    /// Image data of song/track's album cover. Returns nil if the type is not .music
    lazy open var albumArtwork: Data? = {
        guard self.type == .music else { return nil }
        guard let dataString = self.metadata?.artwork else { return nil }
        return Data(base64Encoded: dataString)
    }()

    /// Release date of the song/track. Returns nil if the type is not .music
    lazy open var releaseDate: Date? = {
        guard self.type == .music else { return nil }
        return self.metadata?.creationDate
    }()

    // MARK: - CustomStringConvertible

    open var description: String {
        switch type {
        case .tv:
            return "Title: \(title); Episode: \(episode ?? "nil"); Season: \(season ?? "nil"); Year: \(year ?? "nil")"
        case .movie:
            return "Title: \(title); Year: \(year ?? "nil")"
        case .music:
            return "Title: \(title); Artist: \(artist ?? "nil"); Album: \(album ?? "nil"); Year: \(year ?? "nil")"
        default:
            return "Unkown media type. Cannot describe."
        }
    }

    // MARK: - Initializers

    public init(name: String, path: Path? = nil) {
        rawString = name
        if let p = path {
            fullPath = p.isFile ? p : p + name
        } else {
            fullPath = Path(name)
        }
    }

    public init(fullPath: Path) {
        self.fullPath = fullPath
        self.rawString = fullPath.lastComponent
    }

}
