import Foundation

public extension StringProtocol where Self: RangeReplaceableCollection {
    func removingAllWhitespacesAndNewlines() -> Self {
        return filter { !$0.isNewline && !$0.isWhitespace }
    }
}
