import Foundation
import Nimble
import Quick
import Bedrock
import AwesomeDictionary
@testable import AwesomeTrie

final class ParserLexerSpec: QuickSpec {
    override func spec() {
        describe("Simple Lexing") {
            let inputString = "{ 0 { 0, 1 } }"
            let lexicalOutput = TrieSet<String>.lexCharacters(queryString: inputString.removingAllWhitespacesAndNewlines())
            it("should convert string to tokens successfully") {
                expect(lexicalOutput.first).toNot(beNil())
                expect(lexicalOutput.first!).to(equal(TrieToken.open))
                expect(lexicalOutput[1]).to(equal(TrieToken.other("0")))
                expect(lexicalOutput[2]).to(equal(TrieToken.open))
            }
        }
        describe("Combine Lexing") {
            let inputString = "{ 00 { 0, 1 } }"
            let lexicalOutput = TrieSet<String>.lexCharacters(queryString: inputString.removingAllWhitespacesAndNewlines()).combineCharacterTokens()
            let tokens: [TrieToken] = [.open, .other("00"), .open, .other("0"), .comma, .other("1"), .close, .close]
            it("should convert complex string to tokens successfully") {
                expect(lexicalOutput.first).toNot(beNil())
                expect(lexicalOutput).to(equal(tokens))
            }
        }
        describe("Parsing") {
            let inputString = "{ hello { world, hi }}"
            let parser = TrieSet<String>(queryString: inputString)
            let expectedParser = TrieSet<String>().adding(["hello", "world"]).adding(["hello", "hi"])
            it("should parse into tree correctly") {
                expect(parser).toNot(beNil())
                let resultJSON = try! JSONEncoder().encode(parser!)
                let expectedJSON = try! JSONEncoder().encode(expectedParser)
                expect(resultJSON).to(equal(expectedJSON))
            }
        }
        describe("Compression") {
            let inputString = "{ hello { world { hi, hey }}}"
            let parser = TrieSet<String>(queryString: inputString)
            let expectedParser = TrieSet<String>().adding(["hello", "world", "hi"]).adding(["hello", "world", "hey"])
            it("should compress") {
                expect(parser).toNot(beNil())
                let resultJSON = try! JSONEncoder().encode(parser!)
                let expectedJSON = try! JSONEncoder().encode(expectedParser)
                expect(resultJSON).to(equal(expectedJSON))
                expect(parser!.children.first()!.1.prefix.count).to(equal(2))
            }
        }
    }
}
