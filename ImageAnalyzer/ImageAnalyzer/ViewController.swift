//
//  ViewController.swift
//  ImageAnalyzer
//
//  Created by nabilla on 13/01/24.
//

import UIKit
import Vision

class ViewController: UIViewController {
    
    @IBOutlet weak var imgPhoto: UIImageView!
    private var photosHelper: PhotosGalleryHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photosHelper = PhotosGalleryHelper(delegate: self)
    }

    @IBAction func onTapCameraBarItem(_ sender: Any) {
        photosHelper?.showPicker()
    }
}
  
extension ViewController: PhotosGalleryHelperDelegate {
    func onFinishGetImage(selectedImage: UIImage) {
        self.imgPhoto.image = selectedImage
        self.performVisionRequest(image: selectedImage)
    }
}

extension ViewController {

    var barcodesDetectionRequest: VNDetectBarcodesRequest {
        let request = VNDetectBarcodesRequest( completionHandler: { (request, error) in
            if let detectError = error as NSError? {
                print(detectError)
                return
            } else {
                guard let observations = request.results as? [VNDetectedObjectObservation] else {
                    return
                }
                
                self.visualizeObservation(observations)
            }
        })
        
        return request
    }

    var rectangleDetectionRequest: VNDetectRectanglesRequest {
        let request = VNDetectRectanglesRequest( completionHandler: { (request, error) in
            if let detectError = error as NSError? {
                print(detectError)
                return
            } else {
                guard let observations = request.results as? [VNDetectedObjectObservation] else {
                    return
                }
            
                self.visualizeObservation(observations)
            }
        })
        
        request.maximumObservations = 0
        //request.minimumConfidence = 0.5
        //request.minimumAspectRatio = 0.4
        
        return request
    }

    var faceDetectionRequest: VNDetectFaceRectanglesRequest {
        let request = VNDetectFaceRectanglesRequest( completionHandler: { (request, error) in
            if let detectError = error as NSError? {
                print(detectError)
                return
            } else {
                guard let observations = request.results as? [VNDetectedObjectObservation] else {
                    return
                }
                
                self.visualizeObservation(observations)
            }
        })
        
        return request
    }
    
    var textDetectionRequest: VNDetectTextRectanglesRequest {
        let request = VNDetectTextRectanglesRequest( completionHandler: { (request, error) in
            if let detectError = error as NSError? {
                print(detectError)
                return
            } else {
                guard let observations = request.results as? [VNDetectedObjectObservation] else {
                    return
                }
                
                self.visualizeObservation(observations)
            }
        })
        
        request.reportCharacterBoxes = true
        
        return request
    }
    
    
    func performVisionRequest(image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let requestHandler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: image.cgOrientation,
            options: [:]
        )
            
        let requests = [rectangleDetectionRequest, textDetectionRequest, faceDetectionRequest, barcodesDetectionRequest]

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform(requests)
            } catch let error as NSError {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    private func visualizeObservation(_ observations: [VNDetectedObjectObservation]) {
        DispatchQueue.main.async {
            guard let image = self.imgPhoto.image else {
                print("failed to retrieve image")
                return
            }
            
            let imageSize = image.size
            var transform = CGAffineTransform.identity
                .scaledBy(x: 1, y: -1)
                .translatedBy(x: 0, y: -imageSize.height)
            
            transform = transform.scaledBy(x: imageSize.width, y: imageSize.height)
            
            UIGraphicsBeginImageContextWithOptions(imageSize, true, 0.0)
            let context = UIGraphicsGetCurrentContext()
            image.draw(in: CGRect(origin: .zero, size: imageSize))
            
            context?.saveGState()
            context?.setLineWidth(5.0)
            context?.setLineJoin(.round)
            context?.setStrokeColor(UIColor.red.cgColor)
            context?.setFillColor(UIColor.red.withAlphaComponent(0.3).cgColor)
            
            observations.forEach({ observation in
                let bounds = observation.boundingBox.applying(transform)
                context?.addRect(bounds)
            })
            
            context?.drawPath(using: .fillStroke)
            context?.restoreGState()
            
            let drawnImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            self.imgPhoto.image = drawnImage
        }
    }
}
