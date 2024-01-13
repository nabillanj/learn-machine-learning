import NaturalLanguage

let text = "Trying to do a little more than what's allowed, without suffering consequences"

let tagger = NLTagger(tagSchemes: [.lexicalClass, .language, .script])
tagger.string = text

tagger.enumerateTags(
    in: text.startIndex..<text.endIndex,
    unit: .word,
    scheme: .lexicalClass,
    options: [.omitPunctuation]) { (tag, range) -> Bool in
        print(text[range])
        print(tag?.rawValue ?? "unknown")
        return true
    }
