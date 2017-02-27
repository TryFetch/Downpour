import Foundation
import PathKit
import JSON

// Mac OS includes the AVMetadataCommonKeys in the AVFoundation framework,
// along with the AVAsset class to make retriving file metadata easy
#if os(macOS)
import AVFoundation
#else
// On Linux we define our own metadata keys that correspond with what exiftool
// uses for metadata key names
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
    // These lazy vars will get metadata for all the common keys normally
    // defined in AVFoundation. The vars are lazy, which means it will only
    // perform the getter once
    lazy var title: String? = { return self.getCommonMetadata(AVMetadataCommonKeyTitle) }()
    lazy var creator: String? = { return self.getCommonMetadata(AVMetadataCommonKeyCreator) }()
    lazy var subject: String? = { return self.getCommonMetadata(AVMetadataCommonKeySubject) }()
    lazy var description: String? = { return self.getCommonMetadata(AVMetadataCommonKeyDescription) }()
    lazy var publisher: String? = { return self.getCommonMetadata(AVMetadataCommonKeyPublisher) }()
    lazy var contributer: String? = { return self.getCommonMetadata(AVMetadataCommonKeyContributor) }()
    lazy var creationDate: Date? = {
        guard let dateString = self.creationDateString else { return nil }
        return self.dateFormatter.date(from: dateString)
    }()
    lazy var creationDateString: String? = { return self.getCommonMetadata(AVMetadataCommonKeyCreationDate) }()
    lazy var lastModifiedDate: Date? = {
        guard let dateString = self.lastModifiedDateString else { return nil }
        return self.dateFormatter.date(from: dateString)
    }()
    lazy var lastModifiedDateString: String? = { return self.getCommonMetadata(AVMetadataCommonKeyLastModifiedDate) }()
    lazy var type: String? = { return self.getCommonMetadata(AVMetadataCommonKeyType) }()
    lazy var format: String? = { return self.getCommonMetadata(AVMetadataCommonKeyFormat) }()
    lazy var identifier: String? = { return self.getCommonMetadata(AVMetadataCommonKeyIdentifier) }()
    lazy var source: String? = { return self.getCommonMetadata(AVMetadataCommonKeySource) }()
    lazy var language: String? = { return self.getCommonMetadata(AVMetadataCommonKeyLanguage) }()
    lazy var relation: String? = { return self.getCommonMetadata(AVMetadataCommonKeyRelation) }()
    lazy var location: String? = { return self.getCommonMetadata(AVMetadataCommonKeyLocation) }()
    lazy var copyrights: String? = { return self.getCommonMetadata(AVMetadataCommonKeyCopyrights) }()
    lazy var album: String? = { return self.getCommonMetadata(AVMetadataCommonKeyAlbumName) }()
    lazy var author: String? = { return self.getCommonMetadata(AVMetadataCommonKeyAuthor) }()
    lazy var artist: String? = { return self.getCommonMetadata(AVMetadataCommonKeyArtist) }()
    lazy var artwork: String? = { return self.getCommonMetadata(AVMetadataCommonKeyArtwork) }()
    lazy var make: String? = { return self.getCommonMetadata(AVMetadataCommonKeyMake) }()
    lazy var model: String? = { return self.getCommonMetadata(AVMetadataCommonKeyModel) }()
    lazy var software: String? = { return self.getCommonMetadata(AVMetadataCommonKeySoftware) }()

    // Create a lazy date formatter for the attributes that require a date from
    // string in the ISO 8601 format
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }()

    /// The path to the file
    private var filepath: Path

    /// The errors that occur within the Metadata class
    private enum MetadataError: Swift.Error {
        case missingDependency(dependency: String, helpText: String)
        case couldNotGetMetadata(error: String)
        case missingMetadataKey(key: String)
    }

    /// Initializer that checks to make sure the dependencies are installed
    init(_ path: Path) throws {
        filepath = path
        try hasDependencies()
    }

    private func hasDependencies() throws {
        #if os(Linux)
        let (rc, _) = execute("which exiftool")
        if rc != 0 {
            throw MetadataError.missingDependency(dependency: "exiftool",
                helpText: "On Ubuntu systems, try installing the 'libimage-exiftool-perl' package")
        }
        #endif
    }

    private struct Output {
        var stdout: String?
        var stderr: String?
        init (_ out: String?, _ err: String?) {
            stdout = out
            stderr = err
        }
    }

    private func execute(_ command: String...) -> (Int32, Output) {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = command

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        task.standardOutput = stdoutPipe
        task.standardError = stderrPipe
        task.launch()
        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        let stdout = String(data: stdoutData, encoding: .utf8)
        let stderr = String(data: stderrData, encoding: .utf8)
        task.waitUntilExit()
        return (task.terminationStatus, Output(stdout, stderr))
    }

    public func getCommonMetadata(_ key: String) -> String? {
        do {
            return try getCM(key)
        } catch {
            print("Failed to get file metadata: \n\t\(error)")
        }
        return nil
    }

    private func getCM(_ key: String) throws -> String? {
        #if os(macOS)
        let asset = AVAsset(url: filepath.url)
        let metadataItems = AVMetadataItem.metadataItems(from: asset.commonMetadata, withKey: key, keySpace: nil)
        guard metadataItems.count > 0 else {
            throw MetadataError.missingMetadataKey(key: key)
        }
        return metadataItems.first?.stringValue
        #else
        let (rc, output) = execute("exiftool -j \(fullPath.path)")
        guard rc == 0 else {
            throw MetadataError.couldNotGetMetadata(error: output.stderr)
        }

        let metadataJSON = JSON(output.stdout)
        guard let property = try metadataJSON.get(key) else {
            throw MetadataError.missingMetadataKey(key: key)
        }
        return property
        #endif
        return nil
    }
}
