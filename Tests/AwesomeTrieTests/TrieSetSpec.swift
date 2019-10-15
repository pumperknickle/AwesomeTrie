import Foundation
import Nimble
import Quick
import Bedrock
import AwesomeDictionary
@testable import AwesomeTrie

final class TrieSetSpec: QuickSpec {
    override func spec() {
        let newSet = TrieSet<String>()
        let key1 = ["foo"]
        let key2 = ["foo", "bar"]
        let key3 = ["foo", "boo", "bar"]
        let set1 = newSet.adding(key1).adding(key2).adding(key3)
        describe("adding and removing") {
            let set2 = newSet.adding(key2).adding(key1).adding(key3)
            let set3 = newSet.adding(key3).adding(key2).adding(key1)
            it("deterministic so encoding should be equal") {
                let set1Data = try! JSONEncoder().encode(set1)
                let set2Data = try! JSONEncoder().encode(set2)
                let set3Data = try! JSONEncoder().encode(set3)
                expect(set1Data).to(equal(set2Data))
                expect(set2Data).to(equal(set3Data))
            }
            it("should be able to retrieve data") {
                expect(set1.contains(key1)).to(beTrue())
                expect(set1.contains(key2)).to(beTrue())
                expect(set1.contains(key3)).to(beTrue())
            }
            let set4 = set1.removing(key1)
            let set5 = newSet.adding(key2).adding(key3)
            it("should remove correctly") {
                expect(set4.contains(key1)).toNot(beTrue())
                let set4Data = try! JSONEncoder().encode(set4)
                let set5Data = try! JSONEncoder().encode(set5)
                expect(set4Data).to(equal(set5Data))
            }
        }
        describe("including and excluding") {
            let setIncluding = set1.including(keys: key2)
            it("should only have key1 and key2") {
                expect(setIncluding.contains(key1)).to(beTrue())
                expect(setIncluding.contains(key2)).to(beTrue())
            }
            let setExcluding = set1.excluding(keys: key2)
            it("should only have key1 and key3") {
                expect(setExcluding.contains(key1)).to(beTrue())
                expect(setExcluding.contains(key3)).to(beTrue())
            }
        }
        describe("subtree") {
            let setSubtree = set1.subtree(keys: key1)
            it("should not contains key 1, but contain key2 and key3 with key1 removed") {
                expect(setSubtree.elements().count).to(equal(2))
                expect(setSubtree.contains(key2 - key1)).toNot(beNil())
                expect(setSubtree.contains(key3 - key1)).toNot(beNil())
            }
        }
    }
}
