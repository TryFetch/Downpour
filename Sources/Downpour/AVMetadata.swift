#if !os(Linux)
import Foundation
import AVFoundation
import TrailBlazer

public class AVMetadata: Metadata {
    public lazy var title: String = { return self[.commonKeyTitle] ?? path.string }()
    public let type: MetadataType = .audio
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
#endif
