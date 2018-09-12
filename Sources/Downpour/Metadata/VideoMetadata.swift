import TrailBlazer
import Foundation

open class VideoMetadata: Metadata, CustomStringConvertible {
    public enum Pattern: String, CaseIterable {
        case pretty = "S(\\d{4}|\\d{1,2})[\\-\\.\\s_]?E\\d{1,2}"
        case tricky = "[^\\d](\\d{4}|\\d{1,2})[X\\-\\.\\s_]\\d{1,2}([^\\d]|$)"
        case combined = "(?:S)?(\\d{4}|\\d{1,2})[EX\\-\\.\\s_]\\d{1,2}([^\\d]|$)"
        case altSeason = "Season (\\d{4}|\\d{1,2}) Episode \\d{1,2}"
        case altSeasonSingle = "Season (\\d{4}|\\d{1,2})"
        case altEpisodeSingle = "Episode \\d{1,2}"
        case altSeason2 = "[\\s_\\.\\-\\[]\\d{3}[\\s_\\.\\-\\]]"
        case year = "[\\(?:\\.\\s_\\[](?:19|(?:[2-9])(?:[0-9]))\\d{2}[\\]\\s_\\.\\)]"
    }
    public static let regexOptions: String.CompareOptions = [.regularExpression, .caseInsensitive]

    public static let extensions: [MetadataFormat: [String]] = [
        .video: [
                 "mkv", "flv", "vob", "ogv", "drc",
                 "gifv", "mng", "avi", "mov", "qt",
                 "wmv", "yuv", "rmvb", "asf", "amv",
                 "mp4", "m4p", "m4v", "mpg", "mp2",
                 "mpeg", "mpe", "mpv", "svi", "3g2",
                 "mx4", "roq", "nsv", "f4v", "f4p",
                 "f4a", "f4b"
                ],
        .subtitle: ["srt", "smi", "ssa", "ass", "vtt"]
    ]

    public static let splitCharset = CharacterSet(charactersIn: "eExX-._ ")

    private let _rawString: String
    private let _extension: String?

    open var description: String {
        var desc: String = "\(Swift.type(of: self))(title: \(title)"

        switch type {
        case .video, .subtitle:
            switch type.format {
            case .tv:
                desc += ", season: \(String(describing: season)), episode: \(String(describing: episode))"
            default: break
            }
        default: fatalError("Non video type found in VideoMetadata")
        }

        if let year = self.year {
            desc += ", year: \(year)"
        }

        return desc + ")"
    }

    public required init?(file path: FilePath) {
        guard VideoMetadata.extensions.reduce([], { $0 + $1.value }).contains(path.extension ?? "") else { return nil }
        guard let last = path.lastComponentWithoutExtension else { return nil }
        _rawString = last
        _extension = path.extension
    }

    public init?(filename: String) {
        let comps = filename.components(separatedBy: ".")
        if comps.count > 1 {
            _extension = comps.last
            guard VideoMetadata.extensions.reduce([], { $0 + $1.value }).contains(_extension ?? "") else { return nil }

            _rawString = comps.dropLast().joined(separator: ".")
        } else {
            _rawString = filename
            _extension = nil
        }
    }

    open lazy var type: MetadataFormat = {
        guard let ext = _extension else {
            return .video
        }

        // Sometimes it mestakes the x/h 264 as season 2, episode 64. I don't
        // know of any shows that have 64 episode in a single season, so
        // checking that the episode < 64 should be safe and will resolve these
        // false positives
        if season != nil && (episode ?? 64) < 64 {
            return .video(.tv)
        }

        return .video(.movie)
    }()

    /// Iterates through all of the patterns and returns any match found
    private lazy var seasonEpisode: String? = {
        var _match: Range<String.Index>?
        var _patternMatched: Pattern?
        for (index, pattern) in Pattern.allCases.enumerated() {
            if let __match = _rawString.range(of: pattern, options: VideoMetadata.regexOptions) {
                _match = __match
                _patternMatched = Pattern.allCases[index]
                break
            }
        }
        guard var match = _match, let patternMatched = _patternMatched else { return nil }

        let matchString: String?
        switch patternMatched {
        case .tricky:
            match = _rawString.index(after: match.lowerBound)..<match.upperBound
            matchString = String(_rawString[match])
        case .combined:
            match = match.lowerBound..<match.upperBound
            matchString = String(_rawString[match])
        case .altSeason2:
            let str = _rawString[match].cleanedString
            guard ["264", "720"].contains(str[1...3]) else { return str }
            fallthrough
        default: matchString = String(_rawString[match])
        }

        return matchString
    }()

    private lazy var cleanSeasonEpisode: String? = { return seasonEpisode?.cleanedString }()

    private static let seasonLabel: String = "Season "

    open lazy var season: Int? = {
        guard let both = cleanSeasonEpisode else { return nil }

        guard both.range(of: VideoMetadata.seasonLabel, options: VideoMetadata.regexOptions) == nil else {
            guard let match = _rawString.range(of: Pattern.altSeasonSingle, options: VideoMetadata.regexOptions) else { return nil }
            let string = String(_rawString[match])
            let startIndex = string.startIndex
            let endIndex = string.index(startIndex, offsetBy: VideoMetadata.seasonLabel.count)

            return Int(string.replacingCharacters(in: startIndex..<endIndex, with: "").cleanedString)
        }

        guard both.count != 3 else {
            return Int(both[both.startIndex...both.startIndex].cleanedString)
        }

        let pieces = both.components(separatedBy: VideoMetadata.splitCharset)

        // If we didn't cause a split above, then the following code can not be
        // reliably run
        guard pieces.count > 1 else { return nil }
        // This will never fail
        guard let first = pieces.first else { fatalError("Splitting a string resulted in an empty array") }

        // The size of the first part needs to be between 1 and 2
        if first.count <= 2 && first.count >= 1 {
            return Int(first.cleanedString)
        }

        let startIndex = first.index(after: first.startIndex)
        return Int(first[startIndex..<first.endIndex].cleanedString)
    }()

    private static let episodeLabel: String = "Episode "

    open lazy var episode: Int? = {
        guard let both = cleanSeasonEpisode else { return nil }

        guard both.range(of: VideoMetadata.episodeLabel, options: VideoMetadata.regexOptions) == nil else {
            guard let match = _rawString.range(of: Pattern.altEpisodeSingle, options: VideoMetadata.regexOptions) else { return nil }
            let string = String(_rawString[match])
            let startIndex = string.startIndex
            let endIndex = string.index(startIndex, offsetBy: VideoMetadata.episodeLabel.count)

            return Int(string.replacingCharacters(in: startIndex..<endIndex, with: "").cleanedString)
        }

        guard both.count != 3 else {
            let startIndex = both.index(after: both.startIndex)
            let endIndex = both.index(after: startIndex)
            return Int(both[startIndex...endIndex].cleanedString)
        }

        let pieces = both.components(separatedBy: VideoMetadata.splitCharset)
        var i = 1
        while pieces[i].isEmpty && i < pieces.count {
            i += 1
        }

        return Int(pieces[i].cleanedString)
    }()

    open lazy var year: Int? = {
        guard let match = _rawString.range(of: Pattern.year, options: VideoMetadata.regexOptions) else { return nil }
        return Int(_rawString[match].cleanedString)
    }()

    open lazy var title: String = {
        let _title: String?

        switch type {
        case .video, .subtitle:
            switch type.format {
            case .movie:
                if let year = self.year {
                    let endIndex = _rawString.index(before: _rawString.range(of: String(year))!.lowerBound)
                    _title = String(_rawString[...endIndex])
                } else { _title = nil }
            case .tv:
                if let sEp = seasonEpisode, let sEpRange = _rawString.range(of: sEp), sEpRange.lowerBound != _rawString.startIndex {
                    let endIndex = _rawString.index(before: sEpRange.lowerBound)
                    var string = _rawString[...endIndex]

                    if let year = self.year {
                        let endIndex = string.index(before: string.range(of: String(year))!.lowerBound)
                        string = string[...endIndex]
                    }
                    _title = String(string)
                } else { _title = nil }
            default: _title = nil
            }
        default: fatalError("Non video metadata type found in VideoMetadata")
        }

        if let title = _title {
            var clean = title.cleanedString

            if let uncleanMatch = title.range(of: "\\d+\\.\\d+", options: .regularExpression),
               let tooCleanMatch = clean.range(of: "\\d+ \\d+", options: .regularExpression),
               uncleanMatch == tooCleanMatch {
               clean = clean.replacingCharacters(in: tooCleanMatch, with: title[uncleanMatch])
           }
           return clean
        }

        return _rawString.cleanedString
    }()
}

public extension Downpour where MetadataType: VideoMetadata {
    public var season: Int? { return metadata.season }
    public var episode: Int? { return metadata.episode }
    public var year: Int? { return metadata.year }
}
