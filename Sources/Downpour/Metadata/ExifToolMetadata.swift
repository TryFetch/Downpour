#if os(Linux)
public typealias AudioMetadata = ExifToolMetadata

import SwiftShell
import TrailBlazer
import Foundation

public struct ExifToolMetadata: Metadata, Decodable {
    public let title: String
    public let creation: Date?
    public let filetype: String?
    public let type: MetadataFormat
    public let copyrights: [String]?
    public let albumName: String?
    public let artist: String?
    public let artwork: String?

    private static var _dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }()

    private enum CodingKeys: String, CodingKey {
        case title = "Title"
        case creationDate = "Date/Time Original"
        case type = "File Type"
        case format = "MIME Type"
        case copyrights = "Copyright"
        case albumName = "Album"
        case artist = "Artist"
        case artwork = "Picture"
    }

    public init?(file path: FilePath) {
        guard path.exists else { return nil }
        guard SwiftShell.run("which", "exiftool").succeeded else {
            #if os(macOS)
            fatalError("Missing `exiftool` dependency! On macOS, try installing it with Homebrew by running `brew install exiftool`")
            #else
            fatalError("Missing `exiftool` dependency! On Ubuntu, try installing it by running `sudo apt install -y libimage-exiftool-perl`")
            #endif
        }

        let output = SwiftShell.run("exiftool", "-b", "-All", "-j", path.string).stdout

        guard let exifData = output.data(using: .utf8) else { return nil }
        guard let data = try? JSONDecoder().decode(ExifToolMetadata.self, from: exifData) else { return nil }

        title = data.title.isEmpty ? path.lastComponentWithoutExtension ?? path.string : data.title
        creation = data.creation
        type = data.type
        filetype = data.filetype
        copyrights = data.copyrights
        albumName = data.albumName
        artist = data.artist
        artwork = data.artwork
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        if let creationString = try container.decodeIfPresent(String.self, forKey: .creationDate) {
            creation = ExifToolMetadata._dateFormatter.date(from: creationString)
        } else {
            creation = nil
        }
        filetype = try container.decodeIfPresent(String.self, forKey: .type)
        if let typeComponents = try container.decodeIfPresent(String.self, forKey: .format)?.lowercased().components(separatedBy: "/") {
            if typeComponents.contains("video") {
                throw MetadataError.incorrectFormat(found: .video, expected: .audio)
            } else if typeComponents.contains("audio") {
                type = .audio
            } else {
                throw MetadataError.incorrectFormat(found: .unknown, expected: .audio)
            }
        } else {
            throw MetadataError.incorrectFormat(found: .unknown, expected: .audio)
        }
        copyrights = try container.decodeIfPresent(String.self, forKey: .copyrights)?.components(separatedBy: ", ")
        albumName = try container.decodeIfPresent(String.self, forKey: .albumName)
        artist = try container.decodeIfPresent(String.self, forKey: .artist)
        artwork = try container.decodeIfPresent(String.self, forKey: .artwork)
    }
}

extension Downpour where MetadataType == ExifToolMetadata {
        public var creation: Date? { return metadata.creation }
        public var filetype: String? { return metadata.filetype }
        public var copyrights: [String]? { return metadata.copyrights }
        public var albumName: String? { return metadata.albumName }
        public var artist: String? { return metadata.artist }
        public var artwork: String? { return metadata.artwork }
}
#endif
