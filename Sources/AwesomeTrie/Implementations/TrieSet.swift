import Foundation
import Bedrock
import AwesomeDictionary

public struct TrieSet<Key: BinaryEncodable>: Codable where Key: Codable {
    private let rawChildren: Mapping<Key, NodeType>!
    
    public init(children: Mapping<Key, NodeType>) {
        self.rawChildren = children
    }
}

extension TrieSet: Set {
    public typealias NodeType = TrieNode<Key, Singleton>

    public var children: Mapping<Key, TrieNode<Key, Value>>! { return rawChildren }
}
