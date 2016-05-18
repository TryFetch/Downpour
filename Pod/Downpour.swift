//
//  Downpour.swift
//  Downpour
//
//  Created by Stephen Radford on 18/05/2016.
//  Copyright © 2016 Stephen Radford. All rights reserved.
//

import Foundation

public class Downpour: CustomStringConvertible {

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
            if let match = rawString.rangeOfString(patterns["season"]!, options: .RegularExpressionSearch) {
                return rawString[match]
            } else if let match = rawString.rangeOfString(patterns["altSeason"]!, options: .RegularExpressionSearch) {
                return rawString[match]
            } else if let match = rawString.rangeOfString(patterns["altSeason2"]!, options: .RegularExpressionSearch) {
                return rawString[match].cleanedString
            }

            return nil
        }
    }

    /// The TV Season - e.g. 02
    public var season: String? {
        get {
            if let both = seasonEpisode {

                if both.characters.count > 6 {

                    let match = rawString.rangeOfString(patterns["altSeasonSingle"]!, options: .RegularExpressionSearch)
                    let string = rawString[match!]

                    let startIndex = string.startIndex
                    let endIndex = string.startIndex.advancedBy(6)

                    return string.stringByReplacingCharactersInRange(startIndex...endIndex, withString: "").cleanedString

                } else if both.characters.count == 3 {

                    return both[both.startIndex...both.startIndex].cleanedString

                }


                let charset = NSCharacterSet(charactersInString: "eExX")
                let pieces = both.componentsSeparatedByCharactersInSet(charset)

                if pieces[0].characters.count == 3 {
                    let startIndex = pieces[0].startIndex.advancedBy(1)
                    let endIndex = pieces[0].startIndex.advancedBy(2)
                    return pieces[0][startIndex...endIndex].cleanedString
                }

                return pieces[0].cleanedString

            }
            return nil
        }
    }

    /// The TV Episode - e.g. 22
    public var episode: String? {
        get {
            if let both = seasonEpisode {

                if both.characters.count > 6 {

                    let match = rawString.rangeOfString(patterns["altEpisodeSingle"]!, options: .RegularExpressionSearch)
                    let string = rawString[match!]

                    let startIndex = string.startIndex
                    let endIndex = string.startIndex.advancedBy(6)

                    return string.stringByReplacingCharactersInRange(startIndex...endIndex, withString: "").cleanedString

                } else if both.characters.count == 3 {

                    let startIndex = both.startIndex.advancedBy(1)
                    let endIndex = both.startIndex.advancedBy(2)
                    return both[startIndex...endIndex].cleanedString

                }

                let charset = NSCharacterSet(charactersInString: "eExX")
                let pieces = both.componentsSeparatedByCharactersInSet(charset)

                return pieces[1].cleanedString
            }
            return nil
        }
    }

    /// Is it TV or a Movie?
    public var type: DownpourType {
        get {
            if season != nil {
                return .TV
            }
            return .Movie
        }
    }

    /// Year of release
    public var year: String? {
        get {
            if let match = rawString.rangeOfString(patterns["year"]!, options: .RegularExpressionSearch) {
                let found = rawString[match]
                return found.cleanedString
            }
            return nil
        }
    }

    /// Title of the TV Show or Movie
    public var title: String {
        get {

            if type == .TV {

                if let se = rawString.rangeOfString(seasonEpisode!) where se.startIndex != rawString.startIndex { // check if there is actually a title before the episode string
                    let endIndex = rawString.rangeOfString(seasonEpisode!)!.startIndex.advancedBy(-1)
                    var string = rawString[rawString.startIndex...endIndex].cleanedString
                    if year != nil {
                        let endIndex = rawString.rangeOfString(year!)!.startIndex.advancedBy(-1)
                        string = rawString[rawString.startIndex...endIndex].cleanedString
                    }
                    return string
                }

                return rawString.cleanedString

            } else if year != nil {
                let endIndex = rawString.rangeOfString(year!)!.startIndex.advancedBy(-1)
                return rawString[rawString.startIndex...endIndex].cleanedString
            }

            return rawString.cleanedString

        }
    }

    // MARK: - CustomStringConvertible
    
    public var description: String {
       return "Title: \(title); Episode: \(episode); Season: \(season); Year: \(year)"
    }


    // MARK: - Initializers
    
    public init(string: String) {
        rawString = string
    }

}
