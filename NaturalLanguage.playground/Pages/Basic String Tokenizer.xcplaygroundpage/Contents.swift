import NaturalLanguage

let text = "Push your limit"

let tagger = NLTagger(tagSchemes: [.tokenType])
tagger.string = text

tagger.enumerateTags(
    in: text.startIndex..<text.endIndex,
    unit: .word,
    scheme: .tokenType,
    options: [.omitPunctuation, .omitWhitespace]) { (tag, range) -> Bool in
        print(text[range])
        return true
    }
