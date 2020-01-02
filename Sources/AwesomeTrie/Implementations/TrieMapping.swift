import Foundation
import Bedrock
import AwesomeDictionary

public struct TrieMapping<Key: DataEncodable, Value: Codable>: Codable where Key: Codable {
    private let rawChildren: Mapping<Key, NodeType>!
    
    public init(children: Mapping<Key, TrieNode<Key, Value>>) {
        self.rawChildren = children
    }
}

extension TrieMapping: Trie {
    public typealias NodeType = TrieNode<Key, Value>
    
    public var children: Mapping<Key, TrieNode<Key, Value>>! {
        return rawChildren
    }
}
