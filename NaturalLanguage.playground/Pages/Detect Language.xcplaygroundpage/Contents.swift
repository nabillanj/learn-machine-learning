import NaturalLanguage

let language1 = "你吃了吗"

if let recognizer = NLLanguageRecognizer.dominantLanguage(for: language1) {
    print("Detected \(recognizer.rawValue) for \(language1)")
} else {
    print("Could not recognize language")
}

let recognizer = NLLanguageRecognizer()
recognizer.processString(language1)

// to filter language based on this constrains
//recognizer.languageConstraints = [.english, .spanish, .simplifiedChinese]

let probabilities = recognizer.languageHypotheses(withMaximum: 3)

for (language, probability) in probabilities {
    print("Detected \(language.rawValue), probabilities \(probability)")
}

recognizer.reset()
