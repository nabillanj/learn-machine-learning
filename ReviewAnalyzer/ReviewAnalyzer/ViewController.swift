//
//  ViewController.swift
//  ReviewAnalyzer
//
//  Created by nabilla on 14/01/24.
//

import UIKit
import NaturalLanguage
import CoreML

class ViewController: UIViewController {

    @IBOutlet weak var barClearInput: UIBarButtonItem!
    @IBOutlet weak var txtReview: UITextView!
    @IBOutlet weak var imgReview: UIImageView!
    
    private lazy var reviewML: NLModel? = {
        let configuration = MLModelConfiguration()
        let model = try? NLModel(mlModel: ReviewClassifier(configuration: configuration).model)
        return model
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barClearInput.isEnabled = false
        
        txtReview.layer.borderWidth = 0.5
        txtReview.layer.borderColor = UIColor.gray.cgColor
        txtReview.layer.cornerRadius = 5.0
        
        imgReview.image = UIImage(named: Emoji.neutral.image)
    }
    
    @IBAction func onTapClearInput(_ sender: Any) {
        txtReview.text = ""
        imgReview.image = UIImage(named: Emoji.neutral.image)
    }
}

extension ViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text!

        barClearInput.isEnabled = !(text.isEmpty)
        
        if !text.isEmpty, text != "\n" {
            if let predicted = reviewML?.predictedLabel(for: text),
               let emoji = Emoji(rawValue: predicted) {
                imgReview.image = UIImage(named: emoji.image)
            }
        } else {
            imgReview.image = UIImage(named: Emoji.neutral.image)
        }
    }
}
