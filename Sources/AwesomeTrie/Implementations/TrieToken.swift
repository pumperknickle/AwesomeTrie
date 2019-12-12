import Foundation

public enum TrieToken: Equatable {
    case open, close, comma, other(String)
}

public extension Array where Element == TrieToken {
    func combineCharacterTokens() -> [TrieToken] {
        return combine(s: nil)
    }
    
    func combine(s: String?) -> [TrieToken] {
        guard let firstToken = first else {
            guard let finalString = s else { return [] }
            return [.other(finalString)]
        }
        switch firstToken {
        case .other(let char):
            return s == nil ? Array(dropFirst()).combine(s: char) : Array(dropFirst()).combine(s: s! + char)
        default:
            return s == nil ? [firstToken] + Array(dropFirst()).combine(s: nil) : [.other(s!), firstToken] + Array(dropFirst()).combine(s: nil)
        }
    }
}
