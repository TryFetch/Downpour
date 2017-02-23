//
//  Downpour.swift
//  Downpour
//
//  Created by Stephen Radford on 18/05/2016.
//  Copyright © 2016 Stephen Radford. All rights reserved.
//

import Foundation
import PathKit

#if os(macOS)
import AVFoundation
#endif

open class Downpour: CustomStringConvertible {

    /// The raw string that has not yet been parsed by Downpour.
    var rawString: String

    /// The full path to the file
    var fullPath: Path

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
    var seasonEpisode: String? {
        if let match = rawString.range(of: patterns["season"]!, options: .regularExpression) {
            return rawString[match]
        } else if let match = rawString.range(of: patterns["altSeason"]!, options: .regularExpression) {
            return rawString[match]
        } else if let match = rawString.range(of: patterns["altSeason2"]!, options: .regularExpression) {
            return rawString[match].cleanedString
        }

        return nil
    }

    /// The TV Season - e.g. 02
    open var season: String? {
        if let both = seasonEpisode {

            if both.characters.count > 6 {

                let match = rawString.range(of: patterns["altSeasonSingle"]!, options: .regularExpression)
                let string = rawString[match!]

                let startIndex = string.startIndex
                let endIndex = string.characters.index(string.startIndex, offsetBy: 6)

                return string.replacingCharacters(in: startIndex..<endIndex, with: "").cleanedString

            } else if both.characters.count == 3 {

                return both[both.startIndex...both.startIndex].cleanedString

            }

            let charset = CharacterSet(charactersIn: "eExX")
            let pieces = both.components(separatedBy: charset)

            if pieces[0].characters.count == 3 {
                let startIndex = pieces[0].characters.index(pieces[0].startIndex, offsetBy: 1)
                let endIndex = pieces[0].characters.index(pieces[0].startIndex, offsetBy: 2)
                return pieces[0][startIndex...endIndex].cleanedString
            }

            return pieces[0].cleanedString

        }
        return nil
    }

    /// The TV Episode - e.g. 22
    open var episode: String? {
        if let both = seasonEpisode {

            if both.characters.count > 6 {

                let match = rawString.range(of: patterns["altEpisodeSingle"]!, options: .regularExpression)
                let string = rawString[match!]

                let startIndex = string.startIndex
                let endIndex = string.characters.index(string.startIndex, offsetBy: 6)

                return string.replacingCharacters(in: startIndex..<endIndex, with: "").cleanedString

            } else if both.characters.count == 3 {

                let startIndex = both.characters.index(both.startIndex, offsetBy: 1)
                let endIndex = both.characters.index(both.startIndex, offsetBy: 2)
                return both[startIndex...endIndex].cleanedString

            }

            let charset = CharacterSet(charactersIn: "eExX")
            let pieces = both.components(separatedBy: charset)

            return pieces[1].cleanedString
        }
        return nil
    }

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
    open var type: DownpourType {
        let ext = fullPath.extension ?? ""
        if videoExtensions.contains(ext) {
            if season != nil {
                return .tv
            }
            return .movie
        } else if musicExtensions.contains(ext) {
            return .music
        } else {
            // Get file metadata to check if it has song-related properties
            #if os(macOS)
            let asset = AVAsset(url: fullPath.url)
            let commonMetadata = asset.commonMetadata
            for metadata in commonMetadata where [AVMetadataCommonKeyType, AVMetadataCommonKeyFormat].contains(metadata.commonKey) {
                print(metadata)
            }
            #else
            // Not sure how to get file metadata on linux
            #endif
            return .unknown
        }
    }

    /// Year of release
    open var year: String? {
        if let match = rawString.range(of: patterns["year"]!, options: .regularExpression) {
            let found = rawString[match]
            return found.cleanedString
        }
        return nil
    }

    /// Title of the TV Show or Movie
    open var title: String {
        if type == .tv {
            // Check if there is actually a title before the episode string
            if let se = rawString.range(of: seasonEpisode!), se.lowerBound != rawString.startIndex {
                let endIndex = rawString.index(rawString.range(of: seasonEpisode!)!.lowerBound, offsetBy: -1)
                var string = rawString[rawString.startIndex...endIndex].cleanedString
                if year != nil {
                    let endIndex = rawString.index(rawString.range(of: year!)!.lowerBound, offsetBy: -1)
                    string = rawString[rawString.startIndex...endIndex].cleanedString
                }
                return string
            }

            return rawString.cleanedString

        } else if year != nil {
            let endIndex = rawString.index(rawString.range(of: year!)!.lowerBound, offsetBy: -1)
            return rawString[rawString.startIndex...endIndex].cleanedString
        }

        return rawString.cleanedString
    }

    open var artist: String? {
        guard type == .music else { return nil }
        #if os(macOS)
        let asset = AVAsset(url: fullPath.url)
        let commonMetadata = asset.commonMetadata
        for metadata in commonMetadata where metadata.commonKey == AVMetadataCommonKeyArtist {
            return metadata.stringValue
        }
        #else
            return nil
        #endif
    }

    open var album: String? {
        guard type == .music else { return nil }
        #if os(macOS)
        let asset = AVAsset(url: fullPath.url)
        let commonMetadata = asset.commonMetadata
        for metadata in commonMetadata where metadata.commonKey == AVMetadataCommonKeyAlbumName {
            return metadata.stringValue
        }
        #else
            return nil
        #endif
    }

    // MARK: - CustomStringConvertible

    open var description: String {
       return "Title: \(title); Episode: \(episode); Season: \(season); Year: \(year)"
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
