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

    /// Is it TV, Movie, or Audio?
    open var type: DownpourType {
        if season != nil {
            return .tv
        }
        #if os(macOS)
        return macOSIsAudio(fullPath.url) ? .music : .movie
        #else
        return linuxIsAudio(fullPath.url) ? .music : .movie
        #endif
    }

    private func linuxIsAudio(_ url: URL) -> Bool {
        return false
    }

    private func macOSIsAudio(_ url: URL) -> Bool {
        let asset = AVAsset(url: url)
        return false
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
