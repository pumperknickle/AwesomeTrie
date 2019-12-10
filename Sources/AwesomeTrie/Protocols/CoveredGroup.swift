import Foundation

public protocol CoveredGroup: Covered where Value == Singleton {
    func contains(_ keys: [Key]) -> Bool
    func adding(_ keys: [Key]) -> Self
    func removing(_ keys: [Key]) -> Self
    func toArray() -> [[Key]]
    func addCover() -> Self
    func removeCover() -> Self
}

public extension CoveredGroup {
    func contains(_ keys: [Key]) -> Bool {
        return trie[keys] != nil
    }
    
    func adding(_ keys: [Key]) -> Self {
        return Self(trie: trie.setting(keys: keys, value: Singleton.void), cover: cover)
    }
    
    func removing(_ keys: [Key]) -> Self {
        return Self(trie: trie.deleting(keys: keys), cover: cover)
    }
    
    func toArray() -> [[Key]] {
        return (cover != nil ? [[]] : []) + trie.keySets()
    }
    
    func addCover() -> Self {
        return Self(trie: trie, cover: Singleton.void)
    }
    
    func removeCover() -> Self {
        return Self(trie: trie, cover: nil)
    }
}

