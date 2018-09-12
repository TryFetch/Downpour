import TrailBlazer

public protocol Downpourable {
    associatedtype MetadataType: Metadata
    var metadata: MetadataType { get }

    init?(file path: FilePath)
    init(metadata: MetadataType)
}
