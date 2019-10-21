import Foundation

public protocol UniqueGroup: Trie where Value == Singleton {
    func contains(_ keys: [Key]) -> Bool
    func adding(_ keys: [Key]) -> Self
    func removing(_ keys: [Key]) -> Self
    func toArray() -> [[Key]]
}

public extension UniqueGroup {
    func contains(_ keys: [Key]) -> Bool {
        return self[keys] != nil
    }
    
    func adding(_ keys: [Key]) -> Self {
        return setting(keys: keys, value: Singleton.void)
    }
    
    func removing(_ keys: [Key]) -> Self {
        return deleting(keys: keys)
    }
    
    func toArray() -> [[Key]] {
        return keySets()
    }
}
