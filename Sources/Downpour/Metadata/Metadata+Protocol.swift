import TrailBlazer

public protocol Metadata {
    var type: MetadataFormat { get }
    var title: String { get }

    init?(file path: FilePath)
}
