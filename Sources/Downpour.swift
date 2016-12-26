//
//  Downpour.swift
//  Downpour
//
//  Created by Stephen Radford on 18/05/2016.
//  Copyright © 2016 Stephen Radford. All rights reserved.
//

import Foundation

open class Downpour: CustomStringConvertible {

    /// The raw string that has not yet been parsed by Downpour.
    var rawString: String

    /// The patterns that will be used to fetch various pieces of information from the rawString.
    let patterns: [String:String] = [
        "season": "[Ss]?\\d\\d?[EexX]\\d\\d?",
        "altSeason": "[Ss]eason \\d\\d? [Ee]pisode \\d\\d?",
        "altSeasonSingle": "[Ss]eason \\d\\d?",
        "altEpisodeSingle": "[Ee]pisode \\d\\d?",
        "altSeason2": "[ .-]\\d\\d\\d[ .-]",
        "year": "[(. ](19|20)\\d\\d[ .)]"
    ]

    /// Both the season and the episode together.
    var seasonEpisode: String? {
        get {
            if let match = rawString.range(of: patterns["season"]!, options: .regularExpression) {
                return rawString[match]
            } else if let match = rawString.range(of: patterns["altSeason"]!, options: .regularExpression) {
                return rawString[match]
            } else if let match = rawString.range(of: patterns["altSeason2"]!, options: .regularExpression) {
                return rawString[match].cleanedString
            }

            return nil
        }
    }

    /// The TV Season - e.g. 02
    open var season: String? {
        get {
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
    }

    /// The TV Episode - e.g. 22
    open var episode: String? {
        get {
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
    }

    /// Is it TV or a Movie?
    open var type: DownpourType {
        get {
            if season != nil {
                return .tv
            }
            return .movie
        }
    }

    /// Year of release
    open var year: String? {
        get {
            if let match = rawString.range(of: patterns["year"]!, options: .regularExpression) {
                let found = rawString[match]
                return found.cleanedString
            }
            return nil
        }
    }

    /// Title of the TV Show or Movie
    open var title: String {
        get {

            if type == .tv {

                if let se = rawString.range(of: seasonEpisode!), se.lowerBound != rawString.startIndex { // check if there is actually a title before the episode string
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
    }

    // MARK: - CustomStringConvertible
    
    open var description: String {
       return "Title: \(title); Episode: \(episode); Season: \(season); Year: \(year)"
    }


    // MARK: - Initializers
    
    public init(string: String) {
        rawString = string
    }

}
