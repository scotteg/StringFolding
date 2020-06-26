//
//  StringFoldingTests.swift
//  StringFoldingTests
//
//  Created by Scott Gardner on 6/13/20.
//  Copyright © 2020 Scott Gardner. All rights reserved.
//

import XCTest

extension String {
    func hasCharacter(in characterSet: CharacterSet) -> Bool {
        characterSet.isDisjoint(with: CharacterSet(charactersIn: self)) == false
    }
}

final class StringFoldingTests: XCTestCase {
    
    static var paragraphs: [String]!
    static var foldedParagraphs: [String]!
    static var diacriticParagraphs: [String]!
    static var foldedDiacriticParagraphs: [String]!
    static let diacriticSearchTerm = "M̲a͌ur̉ȉs et̕ el͙em̗en͂t̕um̗ a͌r̉c͝u"

    override class func setUp() {
//        generateDiacriticText()
        
        var path = Bundle(for: type(of: StringFoldingTests())).path(forResource: "LoremIpsum", ofType: "txt")!
        var data = FileManager.default.contents(atPath: path)!
        paragraphs = String(data: data, encoding: .utf8)!.components(separatedBy: .newlines)
        path = Bundle(for: type(of: StringFoldingTests())).path(forResource: "DiacriticLoremIpsum", ofType: "txt")!
        foldedParagraphs = paragraphs.map { $0.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current) }
        data = FileManager.default.contents(atPath: path)!
        diacriticParagraphs = String(data: data, encoding: .utf8)!.components(separatedBy: .newlines)
        foldedDiacriticParagraphs = diacriticParagraphs.map { $0.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current) }
        
//        print("foldedParagraphs == foldedDiacriticParagraphs \(foldedParagraphs! == foldedDiacriticParagraphs!)")
    }
    
    static func generateDiacriticText() {
        let characters = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let path = Bundle(for: type(of: StringFoldingTests())).path(forResource: "LoremIpsum", ofType: "txt")!
        let data = FileManager.default.contents(atPath: path)!
        let paragraphs = String(data: data, encoding: .utf8)!.components(separatedBy: .newlines)
        
        let diacriticCharacters: [Character] = characters
            .map { c in
                guard Bool.random() else { return c }
                let i = (0x0300...0x036F).randomElement()!
                let diacritic = UnicodeScalar(i)
                var string = String(c)
                string.append(String(diacritic!))
                return Character(string)
        }
        
        diacriticParagraphs = paragraphs
            .reduce([String]()) { result, next in
                let words: [Character] = next
                    .map { c in
                        guard let i = characters.firstIndex(of: c) else { return c }
                        return diacriticCharacters[i]
                }
                
                return result + [String(words)]
        }
        
        let textWithDiacritics = diacriticParagraphs.joined(separator: "\n")
        print("textWithDiacritics = \(textWithDiacritics)")
        
        let diacriticCharacterSet = CharacterSet(charactersIn: diacriticCharacters.map(String.init).joined())
        
        let searchTerm = diacriticParagraphs
            .first { $0.hasCharacter(in: diacriticCharacterSet) }!
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { $0.hasCharacter(in: diacriticCharacterSet) }
            .randomElement()!
        
        print("searchTerm = \(searchTerm)")
    }
    
    // MARK: - Tests
    
    func test_localizedStandardContainsInParagraphsPerformance() throws {
        measure {
            (0..<1000).forEach { _ in
                _ = Self.paragraphs
                    .filter { $0.localizedStandardContains(Self.diacriticSearchTerm) }
            }
        }
    }
    
    func test_localizedStandardContainsInDiacriticParagraphsPerformance() throws {
        measure {
            (0..<1000).forEach { _ in
                _ = Self.diacriticParagraphs
                    .filter { $0.localizedStandardContains(Self.diacriticSearchTerm) }
            }
        }
    }
    
    func test_foldedContainsInFoldedParagraphsPerformance() throws {
        measure {
            (0..<1000).forEach { _ in
                let searchTerm = Self.diacriticSearchTerm
                    .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                
                _ = Self.foldedParagraphs.filter { $0.contains(searchTerm) }
            }
        }
    }
    
    func test_foldedContainsInFoldedDiacriticParagraphsPerformance() throws {
        measure {
            (0..<1000).forEach { _ in
                let searchTerm = Self.diacriticSearchTerm
                    .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                
                _ = Self.foldedDiacriticParagraphs.filter { $0.contains(searchTerm) }
            }
        }
    }
    
}
