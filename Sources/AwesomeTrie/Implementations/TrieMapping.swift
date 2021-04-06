import Foundation
import Bedrock
import AwesomeDictionary

public struct TrieMapping<Key: DataEncodable, Value: Codable> {
    private let rawChildren: Mapping<Key, NodeType>!
    
    public init(children: Mapping<Key, NodeType>) {
        self.rawChildren = children
    }
}

extension TrieMapping: Trie {
    public typealias NodeType = TrieNode<Key, Value>
    
    public var children: Mapping<Key, NodeType>! {
        return rawChildren
    }
    
    private enum CodingKeys: String, CodingKey {
        case children
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let children = try container.decode(Mapping<Key, NodeType>.self, forKey: .children)
        self.init(children: children)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(children, forKey: .children)
    }
}
