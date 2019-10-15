import Foundation
import Bedrock
import AwesomeDictionary

public struct TrieNode<Key: BinaryEncodable, Value: Codable>: Codable where Key: Codable {
    private let rawPrefix: [Key]!
    private let rawValue: Value?
    private let rawChildren: [Mapping<Key, TrieNode<Key, Value>>]!
    
    private init(rawPrefix: [Key]!, rawValue: Value?, rawChildren: [Mapping<Key, TrieNode<Key, Value>>]!) {
        self.rawPrefix = rawPrefix
        self.rawValue = rawValue
        self.rawChildren = rawChildren
    }
}

extension TrieNode: Node {
    public var prefix: [Key]! {
        return rawPrefix
    }
    
    public var value: Value? {
        return rawValue
    }
    
    public var children: Mapping<Key, TrieNode<Key, Value>>! {
        return rawChildren.first!
    }
    
    public init(prefix: [Key], value: Value?, children: Mapping<Key, TrieNode<Key, Value>>) {
        self.init(rawPrefix: prefix, rawValue: value, rawChildren: [children])
    }
}
