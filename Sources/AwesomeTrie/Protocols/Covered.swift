import Foundation
import Bedrock
import AwesomeDictionary

public protocol Covered {
	associatedtype TrieType: Trie
	
	typealias Key = TrieType.Key
	typealias CoverType = TrieType.Value
	typealias NodeType = TrieType.NodeType
	
	var trie: TrieType! { get }
	var cover: CoverType? { get }
	
	func subtreeWithCover(keys: [Key]) -> Self
	init(trie: TrieType, cover: CoverType?)
}

public extension Covered {
	func subtreeWithCover(keys: [Key]) -> Self {
		guard let firstKey = keys.first else { return self }
		guard let childNode = trie.children[firstKey] else { return Self(trie: TrieType(children: Mapping<Key, NodeType>()), cover: nil) }
		guard let childResult = childNode.subtreeWithCover(keys: keys, current: cover) else { return Self(trie: TrieType(children: Mapping<Key, NodeType>()), cover: nil) }
		return Self(trie: TrieType(children: childResult.0), cover: childResult.1)
	}
}