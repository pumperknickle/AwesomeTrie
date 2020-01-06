import Foundation
import Nimble
import Quick
import Bedrock
import AwesomeDictionary
@testable import AwesomeTrie

final class CoveredTreeSpec: QuickSpec {
	override func spec() {
		let newMap = TrieMapping<String, UInt256>()
        let key1 = ["foo"]
		let value1 = UInt256.random()
		let value2 = UInt256.random()
		let value3 = UInt256.random()
        let key2 = key1 + ["bar"]
        let key3 = key1 + ["boo"] + ["bar"]
        let map1 = newMap.setting(keys: key1, value: value1).setting(keys: key2, value: value2).setting(keys: key3, value: value3)
		let initialCover = UInt256.random()
		
		let coveredTree = CoveredTrie<String, UInt256>(trie: map1, cover: initialCover)
		let firstTree = coveredTree.subtreeWithCover(keys: key1)
		let secondTree = firstTree.subtreeWithCover(keys: ["bar"])
		let thirdTree = firstTree.subtreeWithCover(keys: ["boo"])
		let fourthTree = thirdTree.subtreeWithCover(keys: ["bar"])
        let randomTree = coveredTree.subtreeWithCover(keys: ["hello"])
		it("calculates covers correctly") {
			expect(coveredTree.cover).to(equal(initialCover))
			expect(firstTree.cover).to(equal(value1))
			expect(secondTree.cover).to(equal(value2))
			expect(thirdTree.cover).to(equal(value1))
			expect(fourthTree.cover).to(equal(value3))
            expect(randomTree.cover).to(equal(initialCover))
            expect(coveredTree.contains(key: key1.first!)).to(beTrue())
            expect(coveredTree.contains(key: "bar")).to(beFalse())
            expect(firstTree.contains(key: key1.first!)).to(beFalse())
            expect(firstTree.contains(key: "bar")).to(beTrue())
            expect(firstTree.contains(key: "boo")).to(beFalse())
            expect(thirdTree.contains(key: "bar")).to(beTrue())
		}
	}
}
