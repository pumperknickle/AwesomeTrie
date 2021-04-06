import Foundation
import Bedrock
import AwesomeDictionary

public struct TrieSet<Key: DataEncodable> {
    private let rawChildren: Mapping<Key, NodeType>!
    
    public init(children: Mapping<Key, NodeType>) {
        self.rawChildren = children
    }
}

extension TrieSet: UniqueGroup {
    public typealias NodeType = TrieNode<Key, Singleton>

    public var children: Mapping<Key, TrieNode<Key, Value>>! { return rawChildren }
    
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
