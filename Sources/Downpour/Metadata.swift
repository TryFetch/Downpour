import Foundation
import PathKit

#if os(Linux)
// On Linux we define our own metadata keys that correspond with what exiftool
// uses for metadata key names
    enum AVMetadataKey: String {
        case commonKeyTitle = "Title"
        case commonKeyCreationDate = "Date/Time Original"
        case commonKeyType = "File Type"
        case commonKeyFormat = "MIME Type"
        case commonKeyCopyrights = "Copyright"
        case commonKeyAlbumName = "Album"
        case commonKeyArtist = "Artist"
        case commonKeyArtwork = "Picture"
    }
#else
// Mac OS/iOS includes the AVMetadataCommonKeys in the AVFoundation framework,
// along with the AVAsset class to make retriving file metadata easy
import AVFoundation
#endif

class Metadata {
    // These lazy vars will get metadata for all the common keys normally
    // defined in AVFoundation. The vars are lazy, which means it will only
    // perform the getter once
    lazy var title: String? = { return self[.commonKeyTitle] }()
    lazy var creationDate: Date? = {
        guard let dateString = self.creationDateString else { return nil }
        return self.dateFormatter.date(from: dateString)
    }()
    lazy var creationDateString: String? = { return self[.commonKeyCreationDate] }()
    lazy var type: String? = { return self[.commonKeyType] }()
    lazy var format: String? = { return self[.commonKeyFormat] }()
    lazy var copyrights: String? = { return self[.commonKeyCopyrights] }()
    lazy var album: String? = { return self[.commonKeyAlbumName] }()
    lazy var artist: String? = { return self[.commonKeyArtist] }()
    lazy var artwork: String? = { return self[.commonKeyArtwork] }()

    #if !os(Linux)
    lazy var publisher: String? = { return self[.commonKeyPublisher] }()
    lazy var creator: String? = { return self[.commonKeyCreator] }()
    lazy var subject: String? = { return self[.commonKeySubject] }()
    lazy var description: String? = { return self[.commonKeyDescription] }()
    lazy var contributer: String? = { return self[.commonKeyContributor] }()
    lazy var lastModifiedDate: Date? = {
        guard let dateString = self.lastModifiedDateString else { return nil }
        return self.dateFormatter.date(from: dateString)
    }()
    lazy var lastModifiedDateString: String? = { return self[.commonKeyLastModifiedDate] }()
    lazy var identifier: String? = { return self[.commonKeyIdentifier] }()
    lazy var source: String? = { return self[.commonKeySource] }()
    lazy var language: String? = { return self[.commonKeyLanguage] }()
    lazy var relation: String? = { return self[.commonKeyRelation] }()
    lazy var location: String? = { return self[.commonKeyLocation] }()
    lazy var author: String? = { return self[.commonKeyAuthor] }()
    lazy var make: String? = { return self[.commonKeyMake] }()
    lazy var model: String? = { return self[.commonKeyModel] }()
    lazy var software: String? = { return self[.commonKeySoftware] }()
    #endif

    /// A DateFormatter for the attributes that require a date from string in the ISO 8601 format
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }()

    // The saved metadata items, so that we don't have to continually get the AVAsset or run exiftool
    #if os(Linux)
    private struct Metadata: Decodable {
        enum MetadataKeys: String, CodingKey {
            case title = "Title"
            case creationDate = "Date/Time Original"
            case type = "File Type"
            case format = "MIME Type"
            case copyrights = "Copyright"
            case albumName = "Album"
            case artist = "Artist"
            case artwork = "Picture"
        }
        var title: String
        var creationDate: String
        var type: String
        var format: String
        var copyrights: String
        var albumName: String
        var artist: String
        var artwork: String

        subscript(key: AVMetadataKey) -> String {
            switch key {
        	case .commonKeyTitle:
                return title
        	case .commonKeyCreationDate:
                return creationDate
        	case .commonKeyType:
                return type
        	case .commonKeyFormat:
                return format
        	case .commonKeyCopyrights:
                return copyrights
        	case .commonKeyAlbumName:
                return albumName
        	case .commonKeyArtist:
                return artist
        	case .commonKeyArtwork:
                return artwork
            default:
                return ""
            }
        }
    }

    private var metadataJSON: Metadata?
    #else
    private var metadataItems: [AVMetadataItem]?
    #endif

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

    /// Checks to verify the system has any required dependencies.
    /// - Throws: If a dependency is missing
    private func hasDependencies() throws {
        #if os(Linux)
        let (rc, _) = execute("which exiftool")
        guard rc == 0 else {
            throw MetadataError.missingDependency(dependency: "exiftool",
                helpText: "On Ubuntu systems, try installing the 'libimage-exiftool-perl' package by running `sudo apt-get install -y libimage-exiftool-perl`")
        }
        #endif
    }

    #if os(Linux)
    /// Struct used to capture the stdout and stderr of a command
    private struct Output {
        var stdout: String?
        var stderr: String?
        init (_ out: String?, _ err: String?) {
            stdout = out
            stderr = err
        }
    }

    /**
     Executes a cli command

     - Parameter command: The array of strings that form the command and arguments

     - Returns: A tuple of the return code and output
    */
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
    #endif

    /**
     Get the common metadata for the specified common metadata key

     - Parameter key: The common metadata key to retrieve from the common metadata for the file

     - Returns: The string value of the common metadata, or nil. If an error occured, this will print it out
    */
    public subscript(_ key: AVMetadataKey) -> String? {
        do {
            // Try and return the Common Metadata value
            return try getCM(key)
        } catch {
            // Print the error that occurred
            print("Failed to get file metadata: \n\t\(error)")
        }
        // Return nil if an error occurs
        return nil
    }

    /**
     Gets the common metadata for the key, throws errors if the key doesn't exist or if metadata could not be retrieved
     - Parameter key: The common metadata key to retrieve from the common metadata for the file

     - Returns: The string value of the common metadata, or nil.
    */
    private func getCM(_ key: AVMetadataKey) throws -> String? {
        #if os(Linux)
        // If we're running Linux, check to see if we've saved an exiftool metadata JSON object
        if metadataJSON == nil {
            // If not, run the exiftool command to get the file's metadata
            let (rc, output) = execute("exiftool -b -All -j \(filepath.absolute)")
            // Throw an error if we failed to get the metadata
            guard rc == 0 else {
                var err: String = ""
                if let stderr = output.stderr {
                    err = stderr
                }
                throw MetadataError.couldNotGetMetadata(error: err)
            }
            guard let stdout = output.stdout else {
                throw MetadataError.couldNotGetMetadata(error: "File does not contain any metadata")
            }

            metadataJSON = try JSONDecoder().decode(Metadata.self, from: stdout.data(using: .utf8)!)
        }
        // Try and retrieve the specified property
        guard let property = metadataJSON?[key] else {
            // Throw an error if the key doesn't exist
            throw MetadataError.missingMetadataKey(key: key.rawValue)
        }
        // Otherwise, return the property
        return property
        #else
        // If we're on macOS/iOS/tvOS/watchOS, check to see if we've saced the common metadataItems
        if metadataItems == nil {
            // If not, get the AVAsset from the filepath url
            let asset = AVAsset(url: filepath.url)
            // Save the common metadata items
            metadataItems = asset.commonMetadata
            // Make sure the asset had common metadata items
            guard let _ = metadataItems else {
                // Throw an error because the asset either has no common metadata, or something happened
                throw MetadataError.couldNotGetMetadata(error: "Unkown problem getting common metadata from AVAsset")
            }
        }
        // Try and get the metadata for the specified key
        let metadata = AVMetadataItem.metadataItems(from: metadataItems!, withKey: key, keySpace: nil)
        // Throws an error if there is no common metadata for the key
        guard metadata.count > 0 else {
            throw MetadataError.missingMetadataKey(key: key.rawValue)
        }
        // Return the first metadata item's string value
        return metadata.first?.stringValue
        #endif
    }
}

