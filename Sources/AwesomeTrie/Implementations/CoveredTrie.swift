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
}
