import NaturalLanguage

let text = "Apple Computer Company was founded on April 1, 1976, by Steve Jobs, Steve Wozniak, and Ronald Wayne as a partnership. The company's first product was the Apple I, a computer designed and hand-built entirely by Wozniak"

let tagger = NLTagger(tagSchemes: [.nameType])
tagger.string = text

tagger.enumerateTags(
    in: text.startIndex..<text.endIndex,
    unit: .word,
    scheme: .nameType,
    options: [.omitPunctuation, .omitWhitespace]) { (tag, range) -> Bool in
        print(text[range])
        print(tag?.rawValue ?? "unknown")
        return true
    }
