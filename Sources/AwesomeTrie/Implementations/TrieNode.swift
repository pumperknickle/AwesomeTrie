import Foundation
import Bedrock
import AwesomeDictionary

public struct TrieNode<Key: DataEncodable, Value: Codable>: Codable {
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
    private enum CodingKeys: String, CodingKey {
        case prefix
        case value
        case children
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let prefix = try container.decode(String.self, forKey: .prefix)
        let keys: [Key]? = prefix.decodeHex()
        if keys == nil { throw DecodingError.dataCorruptedError(forKey: CodingKeys.prefix, in: container, debugDescription: "Prefix corrupted") }
        let value = try? container.decode(Value.self, forKey: .value)
        let children = try container.decode(Mapping<Key, TrieNode<Key, Value>>.self, forKey: .children)
        self.init(prefix: keys!, value: value, children: children)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rawPrefix.toHexArray(), forKey: .prefix)
        try container.encodeIfPresent(rawValue, forKey: .value)
        try container.encode(children, forKey: .children)
    }
    
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
