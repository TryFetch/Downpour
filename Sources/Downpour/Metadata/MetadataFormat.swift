public enum MetadataError: Error {
    case incorrectFormat(found: MetadataFormat, expected: MetadataFormat)
}

public struct MetadataFormat: RawRepresentable, ExpressibleByIntegerLiteral, Hashable, CustomStringConvertible {
    public struct VideoFormat: RawRepresentable, ExpressibleByIntegerLiteral, Hashable, CustomStringConvertible {
        public static let tv: VideoFormat = 0b0000_0001
        public static let movie: VideoFormat = 0b0000_0010
        public static let unknown: VideoFormat = 0

        public let rawValue: UInt8

        public var description: String {
            switch self {
            case .tv: return "tv"
            case .movie: return "movie"
            default: return "unknown"
            }
        }

        public init(rawValue: UInt8) { self.rawValue = rawValue }
        public init(integerLiteral value: UInt8) { self.init(rawValue: value) }
    }

    public let rawValue: UInt8
    var format: VideoFormat { return VideoFormat(rawValue: rawValue >> 4) }

    public var description: String {
        switch self {
        case .video: return "video(\(format))"
        case .subtitle: return "subtitle(\(format))"
        case .audio: return "audio"
        default: return "unknown"
        }
    }

    public static let video: MetadataFormat = 0b0000_0001
    public static let tv: MetadataFormat = .video(format: .tv)
    public static let movie: MetadataFormat = .video(format: .movie)
    public static func video(format: VideoFormat) -> MetadataFormat {
        return MetadataFormat(rawValue: MetadataFormat.video.rawValue | (format.rawValue << 4))
    }
    public static func video(_ format: VideoFormat) -> MetadataFormat {
        return MetadataFormat(rawValue: MetadataFormat.video.rawValue | (format.rawValue << 4))
    }

    public static let subtitle: MetadataFormat = 0b0000_0011
    public static func subtitle(format: VideoFormat) -> MetadataFormat {
        return MetadataFormat(rawValue: MetadataFormat.subtitle.rawValue | (format.rawValue << 4))
    }
    public static func subtitle(_ format: VideoFormat) -> MetadataFormat {
        return MetadataFormat(rawValue: MetadataFormat.subtitle.rawValue | (format.rawValue << 4))
    }

    public static let audio: MetadataFormat = 0b0000_0100
    public static let unknown: MetadataFormat = 0

    public init(rawValue: UInt8) { self.rawValue = rawValue }
    public init(integerLiteral value: UInt8) { self.init(rawValue: value) }
}

