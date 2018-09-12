#if !os(Linux)
public typealias AudioMetadata = AVMetadata

import Foundation
import AVFoundation
import TrailBlazer

public class AVMetadata: Metadata {
    public lazy var title: String = { return self[.commonKeyTitle] ?? path.string }()
    public let type: MetadataFormat = .audio
    public lazy var creationDate: Date? = {
        guard let dateString = self.creationDateString else { return nil }
        return self.dateFormatter.date(from: dateString)
    }()
    public lazy var creationDateString: String? = { return self[.commonKeyCreationDate] }()
    public lazy var format: String? = { return self[.commonKeyFormat] }()
    public lazy var copyrights: String? = { return self[.commonKeyCopyrights] }()
    public lazy var album: String? = { return self[.commonKeyAlbumName] }()
    public lazy var artist: String? = { return self[.commonKeyArtist] }()
    public lazy var artwork: String? = { return self[.commonKeyArtwork] }()
    public lazy var publisher: String? = { return self[.commonKeyPublisher] }()
    public lazy var creator: String? = { return self[.commonKeyCreator] }()
    public lazy var subject: String? = { return self[.commonKeySubject] }()
    public lazy var summary: String? = { return self[.commonKeyDescription] }()
    public lazy var lastModifiedDate: Date? = {
        guard let dateString = self.lastModifiedDateString else { return nil }
        return self.dateFormatter.date(from: dateString)
    }()
    public lazy var lastModifiedDateString: String? = { return self[.commonKeyLastModifiedDate] }()
    public lazy var language: String? = { return self[.commonKeyLanguage] }()
    public lazy var author: String? = { return self[.commonKeyAuthor] }()

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }()

    private let path: FilePath
    private let metadata: [AVMetadataItem]

    public required init?(file path: FilePath) {
        guard path.exists else { return nil }
        self.path = path

        let asset = AVAsset(url: path.url)
        self.metadata = asset.commonMetadata
    }

    public subscript(_ key: AVMetadataKey) -> String? {
        return AVMetadataItem.metadataItems(from: metadata, withKey: key, keySpace: nil).first?.stringValue
    }
}

public extension Downpour where MetadataType: AVMetadata {
    public var title: String { return metadata.title }
    public var type: MetadataFormat { return metadata.type }
    public var creationDate: Date? { return metadata.creationDate }
    public var format: String? { return metadata.format }
    public var copyrights: String? { return metadata.copyrights }
    public var album: String? { return metadata.album }
    public var artist: String? { return metadata.artist }
    public var artwork: String? { return metadata.artwork }
    public var publisher: String? { return metadata.publisher }
    public var creator: String? { return metadata.creator }
    public var subject: String? { return metadata.subject }
    public var summary: String? { return metadata.summary }
    public var lastModifiedDate: Date? { return metadata.lastModifiedData }
    public var language: String? { return metadata.language }
    public var author: String? { return metadata.author }
}
#endif
