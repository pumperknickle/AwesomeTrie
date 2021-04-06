import Foundation
import Bedrock
import AwesomeDictionary

public protocol Trie: Codable {
    associatedtype Key
    associatedtype Value: Codable
    associatedtype NodeType: Node where NodeType.Value == Value, Key == NodeType.Key
    
    typealias Element = ([Key], Value)
    
    var children: Mapping<Key, NodeType>! { get }
    
    subscript(keys: [Key]) -> Value? { get }
    func setting(keys: [Key], value: Value) -> Self
    func deleting(keys: [Key]) -> Self
    func elements() -> [Element]
    func isEmpty() -> Bool
    func keySets() -> [[Key]]
    func values() -> [Value]
    func contains(keys: [Key]) -> Bool
    func including(keys: [Key]) -> Self
    func excluding(keys: [Key]) -> Self
    func subtree(keys: [Key]) -> Self
	func supertree(keys: [Key]) -> Self
	func overwrite(with trie: Self) -> Self
    
    init(children: Mapping<Key, NodeType>)
    init()
}

public extension Trie {
    init() {
        self = Self(children: Mapping<Key, NodeType>())
    }
    
    func isEmpty() -> Bool {
        return children.isEmpty()
    }
    
    func changing(key: Key, node: NodeType?) -> Self {
        guard let node = node else { return Self(children: children.deleting(key: key)) }
        return Self(children: children.setting(key: key, value: node))
    }
    
    func getRoot(key: Key) -> NodeType? {
        return children[key]
    }
    
    subscript(keys: [Key]) -> Value? {
        guard let firstKey = keys.first else { return nil }
        guard let root = getRoot(key: firstKey) else { return nil }
        return root.get(keys: keys)
    }
    
    func setting(keys: [Key], value: Value) -> Self {
        guard let firstKey = keys.first else { return self }
        guard let childNode = getRoot(key: firstKey) else {
            return changing(key: firstKey, node: NodeType(prefix: keys, value: value, children: Mapping<Key, NodeType>()))
        }
        return changing(key: firstKey, node: childNode.setting(keys: keys, to: value))
    }
    
    func contains(keys: [Key]) -> Bool {
        return self[keys] != nil
    }
    
    func deleting(keys: [Key]) -> Self {
        guard let firstKey = keys.first else { return self }
        guard let childNode = getRoot(key: firstKey) else { return self }
        return changing(key: firstKey, node: childNode.deleting(keys: keys))
    }
        
    func keySets() -> [[Key]] {
        return children.values().map { $0.allKeys(keys: []) }.reduce([], +)
    }
    
    func values() -> [Value] {
        return keySets().lazy.reduce([], { (values, keyset) -> [Value] in
            return values + [self[keyset]!]
        })
    }
    
    func elements() -> [Element] {
        return keySets().lazy.reduce([], { (element, keyset) -> [Element] in
            return element + [(keyset, self[keyset]!)]
        })
    }
    
    func including(keys: [Key]) -> Self {
        guard let firstKey = keys.first else { return self }
        guard let childNode = children[firstKey] else { return Self(children: Mapping<Key, NodeType>()) }
        guard let childResult = childNode.including(keys: keys) else { return Self(children: Mapping<Key, NodeType>()) }
        return Self(children: Mapping<Key, NodeType>().setting(key: firstKey, value: childResult))
    }
    
    func excluding(keys: [Key]) -> Self {
        guard let firstKey = keys.first else { return Self(children: Mapping<Key, NodeType>()) }
        guard let childNode = children[firstKey] else { return self }
        return changing(key: firstKey, node: childNode.excluding(keys: keys))
    }
    
    func subtree(keys: [Key]) -> Self {
        guard let firstKey = keys.first else { return self }
        guard let childNode = children[firstKey] else { return Self(children: Mapping<Key, NodeType>()) }
        guard let childResult = childNode.subtree(keys: keys) else { return Self(children: Mapping<Key, NodeType>()) }
        return Self(children: childResult)
    }

	func supertree(keys: [Key]) -> Self {
		guard let firstKey = keys.first else { return self }
		guard let firstChild = children.first() else { return self }
		if children.deleting(key: firstChild.0).first() == nil {
			let childNode = firstChild.1.changing(prefix: keys + firstChild.1.prefix)
			return Self(children: Mapping<Key, NodeType>().setting(key: firstKey, value: childNode))
		}
		return Self(children: Mapping<Key, NodeType>().setting(key: firstKey, value: NodeType(prefix: keys, value: nil, children: children)))
	}
	
	func overwrite(with trie: Self) -> Self {
        return merge(with: trie) { (left, right) -> Value in
            return right
        }
	}
    
    func merge(with trie: Self, combine: (Value, Value) -> Value) -> Self {
        return Self(children: children.merge(with: trie.children, combine: combine))
    }
}
