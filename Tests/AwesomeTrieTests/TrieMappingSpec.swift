import Foundation
import Nimble
import Quick
import Bedrock
import AwesomeDictionary
@testable import AwesomeTrie

final class TrieMappingSpec: QuickSpec {
    override func spec() {
        let newMap = TrieMapping<String, Bool>()
        let key1 = ["foo"]
        let value1 = true
        let value2 = false
        let key2 = ["foo", "bar"]
        let key3 = ["foo", "boo", "bar"]
        let map1 = newMap.setting(keys: key1, value: value1).setting(keys: key2, value: value1).setting(keys: key3, value: value1)
        describe("encoding and decoding") {
            let map1Data = try! JSONEncoder().encode(map1)
            let decodedMap = try! JSONDecoder().decode(TrieMapping<String, Bool>.self, from: map1Data)
            expect(decodedMap.keySets()).to(equal(map1.keySets()))
        }
        describe("resetting") {
            it("shoud reset") {
                let map2 = map1.setting(keys: key1, value: value2)
                expect(map2[key1]).to(equal(value2))
                expect(map2[key2]).to(equal(value1))
            }
        }
        describe("setting and deleting") {
            let map2 = newMap.setting(keys: key2, value: value1).setting(keys: key1, value: value1).setting(keys: key3, value: value1)
            let map3 = newMap.setting(keys: key3, value: value1).setting(keys: key2, value: value1).setting(keys: key1, value: value1)
            it("should be equal") {
                let map1Data = try! JSONEncoder().encode(map1)
                let map2Data = try! JSONEncoder().encode(map2)
                let map3Data = try! JSONEncoder().encode(map3)
                expect(map1Data).to(equal(map2Data))
                expect(map2Data).to(equal(map3Data))
            }
            it("should be able to retrieve data") {
                expect(map1[key1]).toNot(beNil())
                expect(map1[key2]).toNot(beNil())
                expect(map1[key3]).toNot(beNil())
            }
            it("should be able to get all keys") {
                expect(map1.keySets().count).to(equal(3))
            }
            let map4 = map1.deleting(keys: key1)
            let map5 = newMap.setting(keys: key3, value: value1).setting(keys: key2, value: value1)
            it("should delete correctly") {
                let map4Data = try! JSONEncoder().encode(map4)
                let map5Data = try! JSONEncoder().encode(map5)
                expect(map4Data).to(equal(map5Data))
            }
        }
        describe("including and excluding") {
            let map1Including = map1.including(keys: key2)
            it("should only have key 1 and key 2") {
                expect(map1Including.elements().count).to(equal(2))
                expect(map1Including[key1]).toNot(beNil())
                expect(map1Including[key2]).toNot(beNil())
            }
            let map2Excluding = map1.excluding(keys: key2)
            it("should only have key 1 and key 3") {
                expect(map2Excluding.elements().count).to(equal(2))
                expect(map2Excluding[key1]).toNot(beNil())
                expect(map2Excluding[key3]).toNot(beNil())
            }
        }
        describe("subtree") {
            let map1Including = map1.including(keys: key1)
            it("should contain key 1, 2 and 3") {
                expect(map1Including[key1]).toNot(beNil())
                expect(map1Including[key2]).toNot(beNil())
                expect(map1Including[key3]).toNot(beNil())
            }
            let map1Subtree = map1Including.subtree(keys: key1)
            it("should not contain key 1, but contain key 2, and 3") {
                expect(map1Subtree.elements().count).to(equal(2))
                expect(map1Subtree[key2 - key1]).toNot(beNil())
                expect(map1Subtree[key3 - key1]).toNot(beNil())
            }
        }
		describe("supertree") {
            let map1Including = map1.including(keys: key1)
			let map1Supertree = map1Including.supertree(keys: key1)
			it("should contain extended keys 1, 2, and 3") {
				expect(map1Supertree[key1 + key1]).toNot(beNil())
				expect(map1Supertree[key1 + key2]).toNot(beNil())
				expect(map1Supertree[key1 + key3]).toNot(beNil())
			}
			let map1Subtree = map1Including.subtree(keys: key1)
			let map1Super = map1Subtree.supertree(keys: key1)
			it("should contain key 2 and 3") {
				expect(map1Super.elements().count).to(equal(2))
                expect(map1Super[key2]).toNot(beNil())
                expect(map1Super[key3]).toNot(beNil())
			}
		}
		let someMapping = TrieMapping<String, String>()
		let v1 = "hello"
		let v2 = "world"
		let v3 = "hello world"
		let map3 = someMapping.setting(keys: key1, value: v1).setting(keys: key2, value: v2)
		let map4 = someMapping.setting(keys: key2, value: v1).setting(keys: key3, value: v3)
		describe("overwriting") {
			let overwritten = map3.overwrite(with: map4)
			expect(overwritten[key1]).to(equal(v1))
			expect(overwritten[key2]).to(equal(v1))
			expect(overwritten[key3]).to(equal(v3))
		}
    }
}
