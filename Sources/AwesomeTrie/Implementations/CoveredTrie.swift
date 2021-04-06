import Foundation
import Bedrock
import AwesomeDictionary

public struct CoveredTrie<Key: DataEncodable, Value: Codable> {
	private let rawTrie: TrieType!
	private let rawCover: CoverType?
	
	public init(trie: TrieType, cover: CoverType?) {
		rawTrie = trie
		rawCover = cover
	}
}

extension CoveredTrie: Covered {
	public typealias TrieType = TrieMapping<Key, Value>
	
	public var trie: TrieType! { return rawTrie }
	public var cover: CoverType? { return rawCover }
    
    private enum CodingKeys: String, CodingKey {
        case trie
        case cover
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let trie = try container.decode(TrieType.self, forKey: .trie)
        let cover = try container.decode(CoverType.self, forKey: .cover)
        self.init(trie: trie, cover: cover)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rawTrie, forKey: .trie)
        if let cover = rawCover { try container.encode(cover, forKey: .cover) }
    }
}
