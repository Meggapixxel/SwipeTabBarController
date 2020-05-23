import Foundation

// MARK: - Identifier
protocol P_Identifier {
    associatedtype KeyType
    var wrappedValue: KeyType { get }
    init(wrappedValue: KeyType)
}
protocol P_Identifiable {
    associatedtype IdentifierType: P_Identifier
}

protocol P_IdentifierDecodable: P_Identifier, Decodable where KeyType: Decodable { }
extension P_IdentifierDecodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let wrappedValue = try container.decode(KeyType.self)
        self.init(wrappedValue: wrappedValue)
    }
}
protocol P_IdentifiableDecodable: P_Identifiable where IdentifierType: P_IdentifierDecodable {
    
}

struct Identifier<T, KeyType: Decodable>: P_IdentifierDecodable {
    
    let wrappedValue: KeyType
    
    init(wrappedValue: KeyType) {
        self.wrappedValue = wrappedValue
    }
    
}

// MARK: - Sample models
struct SampleModelArtist: P_Identifiable {
    typealias IdentifierType = Identifier<SampleModelArtist, String>

    let id: IdentifierType
    let name: String
    let recordIds: [SampleModelRecord.IdentifierType]
}

struct SampleModelRecord: P_Identifiable {
    typealias IdentifierType = Identifier<SampleModelRecord, String>

    let id: IdentifierType
    let name: String
    let artistId: SampleModelArtist.IdentifierType
    let songIds: [SampleModelSong.IdentifierType]
}

struct SampleModelSong: P_Identifiable {
    typealias IdentifierType = Identifier<SampleModelSong, String>

    let id: IdentifierType
    let name: String
    let recordId: SampleModelRecord.IdentifierType
    let artistId: SampleModelArtist.IdentifierType
}

// MARK: - Sample API
struct MusicApi {
    func findArtistById(_ id: SampleModelArtist.IdentifierType) -> SampleModelArtist? {
        return nil
    }

    func findRecordById(_ id: SampleModelRecord.IdentifierType) -> SampleModelRecord? {
        return nil
    }

    func findSongById(_ id: SampleModelSong.IdentifierType) -> SampleModelSong? {
        return nil
    }
}
