import TrailBlazer

public protocol Downpourable {
    associatedtype MetadataType: Metadata
    var metadata: MetadataType { get }

    init?(file path: FilePath)
    init(metadata: MetadataType)
}

public extension Downpourable {
    public init?(file path: FilePath) {
        guard let _md = MetadataType(file: path) else { return nil }
        self.init(metadata: _md)
    }
}
