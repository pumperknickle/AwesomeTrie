import Foundation
import AwesomeDictionary

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

public extension UniqueGroup where Key == String {
    init?(queryString: String) {
        let tokens = Self.lexCharacters(queryString: queryString.removingAllWhitespacesAndNewlines()).combineCharacterTokens()
        guard let firstToken = tokens.first else { return nil }
        if firstToken != TrieToken.open { return nil }
        guard let result = Mapping<Key, NodeType>().parse(tokens: Array(tokens.dropFirst())) else { return nil }
        if !result.1.isEmpty { return nil }
        self = Self(children: result.0)
    }
        
    static func lexCharacters(queryString: String) -> [TrieToken] {
        guard let firstChar = queryString.first else { return [] }
        switch firstChar {
        case ",":
            return [.comma] + Self.lexCharacters(queryString: String(queryString.dropFirst()))
        case "{":
            return [.open] + Self.lexCharacters(queryString: String(queryString.dropFirst()))
        case "}":
            return [.close] + Self.lexCharacters(queryString: String(queryString.dropFirst()))
        default:
            return [.other(String(firstChar))] + Self.lexCharacters(queryString: String(queryString.dropFirst()))
        }
    }
}

