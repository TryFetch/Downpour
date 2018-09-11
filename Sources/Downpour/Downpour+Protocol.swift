import TrailBlazer

@dynamicMemberLookup
public protocol Downpourable {
    associatedtype MetadataType: Metadata
    var metadata: MetadataType? { get set }

    init()
    init(metadata: MetadataType)
    subscript<MetadataValue>(dynamicMember member: String) -> MetadataValue? { get }
}

public extension Downpourable {
    public init(metadata: MetadataType) {
        self.init()
        self.metadata = metadata
    }

    public init?(file path: FilePath) {
        guard let _md = MetadataType(file: path) else { return nil }
        self.init(metadata: _md)
    }
}

public protocol Metadata {
    var type: MetadataType { get }
    var title: String { get }

    init?(file path: FilePath)
}

public enum MetadataType {
    public enum VideoType {
        case tv
        case movie
        case unknown
    }

    case video(VideoType)
    case audio
    case unknown
}
