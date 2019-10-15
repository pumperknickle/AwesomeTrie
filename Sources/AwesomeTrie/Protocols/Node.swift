import Foundation
import Bedrock
import AwesomeDictionary

public protocol Node: Codable {
    associatedtype Key: BinaryEncodable
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
    
    init(prefix: [Key], value: Value?, children: Mapping<Key, Self>)
}

public extension Node {
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
}
