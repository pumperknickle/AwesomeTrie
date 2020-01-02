import Foundation
import Bedrock
import AwesomeDictionary

public protocol Node: Codable {
    associatedtype Key: DataEncodable
    associatedtype Value: Codable
    
    var prefix: [Key]! { get }
    var value: Value? { get }
    var children: Mapping<Key, Self>! { get }
    
    func get(keys: [Key]) -> Value?
    func setting(keys: [Key], to value: Value) -> Self
    func deleting(keys: [Key]) -> Self?
    func including(keys: [Key]) -> Self?
    func excluding(keys: [Key]) -> Self?
    func subtree(keys: [Key]) -> Mapping<Key, Self>?
	func overwrite(with node: Self) -> Self
	func subtreeWithCover(keys: [Key], current: Value?) -> (Mapping<Key, Self>, Value?)?
    
    init(prefix: [Key], value: Value?, children: Mapping<Key, Self>)
}

public extension Node {
	func subtreeWithCover(keys: [Key], current: Value?) -> (Mapping<Key, Self>, Value?)? {
		let nextCurrent = value ?? current
		if prefix.starts(with: keys) {
            let suffix = prefix - keys
            guard let firstSuffix = suffix.first else { return (children, nextCurrent) }
            return (Mapping<Key, Self>().setting(key: firstSuffix, value: Self(prefix: suffix, value: value, children: children)), current)
        }
        if !keys.starts(with: prefix) { return nil }
        let suffix = keys - prefix
        let firstSuffix = suffix.first!
        guard let child = children[firstSuffix] else { return nil }
        return child.subtreeWithCover(keys: suffix, current: nextCurrent)
	}
	
    func getChild(_ key: Key) -> Self? {
        return children[key]
    }
    
    func changing(prefix: [Key]) -> Self {
        return Self(prefix: prefix, value: value, children: children)
    }
    
    func changing(value: Value?) -> Self {
        return Self(prefix: prefix, value: value, children: children)
    }
    
    func changing(children: Mapping<Key, Self>) -> Self {
        return Self(prefix: prefix, value: value, children: children)
    }
    
    func changing(child: Key, node: Self?) -> Self {
        return node != nil ? changing(children: children.setting(key: child, value: node!)) : changing(children: children.deleting(key: child))
    }
    
    func get(keys: [Key]) -> Value? {
        if !keys.starts(with: prefix) { return nil }
        let suffix = keys - prefix
        guard let firstValue = suffix.first else { return value }
        guard let childNode = getChild(firstValue) else { return nil }
        return childNode.get(keys: suffix)
    }
    
    func allKeys(keys: [Key]) -> [[Key]] {
        let newKey = keys + prefix
        return children.elements().map { $0.1.allKeys(keys: newKey) }.reduce([], +) + (value == nil ? [] : [newKey])
    }
    
    func setting(keys: [Key], to value: Value) -> Self {
        if keys.count >= prefix.count && keys.starts(with: prefix) {
            let suffix = keys - prefix
            guard let firstValue = suffix.first else { return changing(value: value) }
            guard let childNode = getChild(firstValue) else { return changing(child: firstValue, node: Self(prefix: suffix, value: value, children: Mapping<Key, Self>())) }
            return changing(child: firstValue, node: childNode.setting(keys: suffix, to: value))
        }
        if prefix.count > keys.count && prefix.starts(with: keys) {
            let suffix = prefix - keys
            return Self(prefix: keys, value: value, children: Mapping<Key, Self>().setting(key: suffix.first!, value: changing(prefix: suffix)))
        }
        let parentPrefix = keys ~> prefix
        let newPrefix = keys - parentPrefix
        let oldPrefix = prefix - parentPrefix
        let newNode = Self(prefix: newPrefix, value: value, children: Mapping<Key, Self>())
        let oldNode = changing(prefix: oldPrefix)
        return Self(prefix: parentPrefix, value: nil, children: Mapping<Key, Self>().setting(key: newPrefix.first!, value: newNode).setting(key: oldPrefix.first!, value: oldNode))
    }
    
    func deleting() -> Self? {
        if children.isEmpty() { return nil }
        let childElements = children.elements()
        if childElements.count > 1 { return changing(value: nil) }
        let onlyChild = childElements.first!.1
        return onlyChild.changing(prefix: prefix + onlyChild.prefix)
    }
    
    func deleting(keys: [Key]) -> Self? {
        if !keys.starts(with: prefix) { return self }
        let suffix = keys - prefix
        guard let firstValue = suffix.first else { return deleting() }
        guard let child = getChild(firstValue) else { return self }
        guard let childResult = child.deleting(keys: suffix) else {
            if value != nil { return changing(child: firstValue, node: nil) }
            let childElements = children.elements()
            if childElements.count != 2 { return changing(child: firstValue, node: nil) }
            let childNode = childElements.first(where: { $0.0 != firstValue })!
            return childNode.1.changing(prefix: prefix + childNode.1.prefix)
        }
        return changing(child: firstValue, node: childResult)
    }
    
    func including(keys: [Key]) -> Self? {
        if prefix.starts(with: keys) { return self }
        if !keys.starts(with: prefix) { return nil }
        let suffix = keys - prefix
        guard let firstSuffix = suffix.first else { return self }
        guard let child = children[firstSuffix] else { return nil }
        guard let childResult = child.including(keys: suffix) else { return nil }
        return changing(children: Mapping<Key, Self>().setting(key: firstSuffix, value: childResult))
    }
    
    func excluding(keys: [Key]) -> Self? {
        if prefix.starts(with: keys) { return nil }
        if !keys.starts(with: prefix) { return self }
        let suffix = keys - prefix
        guard let firstSuffix = suffix.first else { return nil }
        guard let child = children[firstSuffix] else { return self }
        guard let childResult = child.excluding(keys: suffix) else {
            if value != nil { return changing(child: firstSuffix, node: nil) }
            let childElements = children.elements()
            if childElements.count != 2 { return changing(child: firstSuffix, node: nil) }
            let childNode = childElements.first(where: { $0.0 != firstSuffix })!
            return childNode.1.changing(prefix: prefix + childNode.1.prefix)
        }
        return changing(child: firstSuffix, node: childResult)
    }
    
    func subtree(keys: [Key]) -> Mapping<Key, Self>? {
        if prefix.starts(with: keys) {
            let suffix = prefix - keys
            guard let firstSuffix = suffix.first else { return children }
            return Mapping<Key, Self>().setting(key: firstSuffix, value: Self(prefix: suffix, value: value, children: children))
        }
        if !keys.starts(with: prefix) { return nil }
        let suffix = keys - prefix
        let firstSuffix = suffix.first!
        guard let child = children[firstSuffix] else { return nil }
        return child.subtree(keys: suffix)
    }
	
	func overwrite(with node: Self) -> Self {
		if node.prefix.starts(with: prefix) && prefix.count == node.prefix.count {
			return Self(prefix: prefix, value: node.value ?? value, children: children.overwrite(with: node.children))
		}
		if prefix.starts(with: node.prefix) {
			let suffix = prefix - node.prefix
			let firstSuffix = suffix.first!
			guard let currentChild = node.children[firstSuffix] else {
				let newChildren = node.children.setting(key: firstSuffix, value: changing(prefix: suffix))
				return node.changing(children: newChildren)
			}
			let newChildren = node.children.setting(key: firstSuffix, value: changing(prefix: suffix).overwrite(with: currentChild))
			return node.changing(children: newChildren)
		}
		if node.prefix.starts(with: prefix) {
			let suffix = node.prefix - prefix
			let firstSuffix = suffix.first!
			guard let currentChild = children[firstSuffix] else {
				let newChildren = children.setting(key: firstSuffix, value: node.changing(prefix: suffix))
				return changing(children: newChildren)
			}
			let newChildren = children.setting(key: firstSuffix, value: node.changing(prefix: suffix).overwrite(with: currentChild))
			return changing(children: newChildren)
		}
		let commonPrefix = node.prefix ~> prefix
		let nodeSuffix = node.prefix - commonPrefix
		let suffix = prefix - commonPrefix
		return Self(prefix: commonPrefix, value: nil, children: Mapping<Key, Self>().setting(key: nodeSuffix.first!, value: node.changing(prefix: nodeSuffix)).setting(key: suffix.first!, value: changing(prefix: suffix)))
	}
}

extension Mapping where Key: BinaryEncodable, Value: Node {
	func overwrite(with map: Self) -> Self {
		if ((self.trueNode == nil) != (map.trueNode == nil) && (self.falseNode == nil) != (map.falseNode == nil)) {
			return Self(trueNode: self.trueNode ?? map.trueNode!, falseNode: self.falseNode ?? map.falseNode!)
		}
		return elements().reduce(map) { (result, entry) -> Self in
			guard let exisingElement = result[entry.0] else { return result.setting(key: entry.0, value: entry.1) }
			return result.setting(key: entry.0, value: exisingElement.overwrite(with: entry.1))
		}
	}
}

public extension Mapping where Key == String, Value: Node, Value.Value == Singleton, Value.Key == String {
    func parse(tokens: [TrieToken]) -> (Self, [TrieToken])? {
        guard let firstToken = tokens.first else { return (self, []) }
        switch firstToken {
        case .close:
            return (self, Array(tokens.dropFirst()))
        case .other(let str):
            guard let result = Value(prefix: [str], value: nil, children: Mapping<Key, Value>()).parse(tokens: Array(tokens.dropFirst())) else { return nil }
            return setting(key: str, value: result.0).parse(tokens: result.1)
        default:
            return nil
        }
    }
}

public extension Node where Key == String, Value == Singleton {
    func parse(tokens: [TrieToken]) -> (Self, [TrieToken])? {
        guard let firstToken = tokens.first else { return nil }
        switch firstToken {
        case .open:
            guard let result = children.parse(tokens: Array(tokens.dropFirst())) else { return nil }
            return changing(children: result.0).parse(tokens: result.1)
        case .comma:
            guard let firstChild = children.first() else { return (self.changing(value: Singleton.void), Array(tokens.dropFirst())) }
            if children.elements().count != 1 { return (self, Array(tokens.dropFirst())) }
            return (firstChild.1.changing(prefix: prefix + firstChild.1.prefix), Array(tokens.dropFirst()))
        case .close:
            guard let firstChild = children.first() else { return (self.changing(value: Singleton.void), tokens) }
            if children.elements().count != 1 { return (self, tokens) }
            return (firstChild.1.changing(prefix: prefix + firstChild.1.prefix), tokens)
        default:
            return nil
        }
    }
}
