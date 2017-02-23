import Foundation
import PathKit

#if os(macOS)
import AVFoundation
#else
private let AVMetadataCommonKeyTitle: String = "Title"
private let AVMetadataCommonKeyCreator: String = ""
private let AVMetadataCommonKeySubject: String = ""
private let AVMetadataCommonKeyDescription: String = ""
private let AVMetadataCommonKeyPublisher: String = "Copyright"
private let AVMetadataCommonKeyContributor: String = ""
private let AVMetadataCommonKeyCreationDate: String = "Date/Time Original"
private let AVMetadataCommonKeyLastModifiedDate: String = AVMetadataCommonKeyCreationDate
private let AVMetadataCommonKeyType: String = "File Type"
private let AVMetadataCommonKeyFormat: String = "MIME Type"
private let AVMetadataCommonKeyIdentifier: String = ""
private let AVMetadataCommonKeySource: String = ""
private let AVMetadataCommonKeyLanguage: String = ""
private let AVMetadataCommonKeyRelation: String = ""
private let AVMetadataCommonKeyLocation: String = ""
private let AVMetadataCommonKeyCopyrights: String = "Copyright"
private let AVMetadataCommonKeyAlbumName: String = "Album"
private let AVMetadataCommonKeyAuthor: String = ""
private let AVMetadataCommonKeyArtist: String = "Artist"
private let AVMetadataCommonKeyArtwork: String = "Picture"
private let AVMetadataCommonKeyMake: String = ""
private let AVMetadataCommonKeyModel: String = ""
private let AVMetadataCommonKeySoftware: String = ""
#endif

class Metadata {
    lazy var title: String? = {
        return getCommonMetadata(AVMetadataCommonKeyTitle)
    }()
    lazy var creator: String? = {
        return getCommonMetadata(AVMetadataCommonKeyCreator)
    }()
    lazy var subject: String? = {
        return getCommonMetadata(AVMetadataCommonKeySubject)
    }()
    lazy var description: String? = {
        return getCommonMetadata(AVMetadataCommonKeyDescription)
    }()
    lazy var publisher: String? = {
        return getCommonMetadata(AVMetadataCommonKeyPublisher)
    }()
    lazy var contributer: String? = {
        return getCommonMetadata(AVMetadataCommonKeyContributor)
    }()
    lazy var creationDate: Date? = {
        guard let dateString = getCommonMetadata(AVMetadataCommonKeyCreationDate) else { return nil }
        return dateFormatter.date(from: dateString)
    }()
    lazy var lastModifiedDate: Date? = {
        guard let dateString = getCommonMetadata(AVMetadataCommonKeyLastModifiedDate) else { return nil }
        return dateFormatter.date(from: dateString)
    }()
    lazy var type: String? = {
        return getCommonMetadata(AVMetadataCommonKeyType)
    }()
    lazy var format: String? = {
        return getCommonMetadata(AVMetadataCommonKeyFormat)
    }()
    lazy var identifier: String? = {
        return getCommonMetadata(AVMetadataCommonKeyIdentifier)
    }()
    lazy var source: String? = {
        return getCommonMetadata(AVMetadataCommonKeySource)
    }()
    lazy var language: String? = {
        return getCommonMetadata(AVMetadataCommonKeyLanguage)
    }()
    lazy var relation: String? = {
        return getCommonMetadata(AVMetadataCommonKeyRelation)
    }()
    lazy var location: String? = {
        return getCommonMetadata(AVMetadataCommonKeyLocation)
    }()
    lazy var copyrights: String? = {
        return getCommonMetadata(AVMetadataCommonKeyCopyrights)
    }()
    lazy var album: String? = {
        return getCommonMetadata(AVMetadataCommonKeyAlbumName)
    }()
    lazy var author: String? = {
        return getCommonMetadata(AVMetadataCommonKeyAuthor)
    }()
    lazy var artist: String? = {
        return getCommonMetadata(AVMetadataCommonKeyArtist)
    }()
    lazy var artwork: String? = {
        return getCommonMetadata(AVMetadataCommonKeyArtwork)
    }()
    lazy var make: String? = {
        return getCommonMetadata(AVMetadataCommonKeyMake)
    }()
    lazy var model: String? = {
        return getCommonMetadata(AVMetadataCommonKeyModel)
    }()
    lazy var software: String? = {
        return getCommonMetadata(AVMetadataCommonKeySoftware)
    }()

    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }()

    private var filepath: Path

    init(_ path: Path) {
        filepath = path
    }

    private func getCommonMetadata(_ key: String) -> String? {
        #if os(macOS)
        let asset = AVAsset(url: filepath.url)
        for metadata in asset.commonMetadata where metadata.commonKey == key {
            return metadata.stringValue
        }
        #else
        // Use shell to check if 
        #endif
        return nil
    }
}
