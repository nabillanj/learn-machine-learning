//
//  PhotosGalleryHelper.swift
//  ImageAnalyzer
//
//  Created by nabilla on 13/01/24.
//

import Foundation
import PhotosUI

let MAX_SIZE_IMAGE_PICKER = 5.0

extension UINavigationController {
    static func presentToRootViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        UIApplication.shared.windows
            .filter { $0.isKeyWindow }
            .first?
            .rootViewController?
            .present(viewController, animated: animated, completion: completion)
    }
}

protocol PhotosGalleryHelperDelegate {
    func onFinishGetImage(selectedImage: UIImage)
}

class PhotosGalleryHelper: NSObject {

    private let imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        return imagePicker
    }()
    
    private let actionSheet: UIAlertController = {
        let actionSheet = UIAlertController(title: "Select Image", message: "", preferredStyle: .actionSheet)
        return actionSheet
    }()
    
    var delegate: PhotosGalleryHelperDelegate?
    
    init(delegate: PhotosGalleryHelperDelegate? = nil) {
        super.init()
        self.setActionSheet()
        self.delegate = delegate
    }
    
    func showPicker() {
        UINavigationController.presentToRootViewController(actionSheet, animated: true)
    }
    
    private func canOpenGallery() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
            case .authorized, .limited:
                return true
            default:
                if #available(iOS 14, *) {
                    PHPhotoLibrary.requestAuthorization(for: .readWrite) { [unowned self] (status) in
                        DispatchQueue.main.async { [weak self] in
                            if status == .authorized || status == .limited {
                                return
                            } else {
                                self?.goToSettings()
                                return
                            }
                        }
                    }
                }
                
                self.goToSettings()
                return false
        }
    }
    
    private func goToSettings() {
        let controller = UIAlertController(title: "Error", message: "Allow authorization through Settings.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        controller.addAction(action)
        UINavigationController.presentToRootViewController(controller, animated: true)
    }
    
    private func openImagePicker() {
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .photoLibrary
        if self.canOpenGallery() {
            UINavigationController.presentToRootViewController(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    private func onClickSelectCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.showsCameraControls = true
            if self.canOpenGallery() {
                UINavigationController.presentToRootViewController(self.imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    private func setActionSheet() {
        self.actionSheet.addAction(UIAlertAction(
            title: "Camera",
            style: .default,
            handler: { _ in
                self.onClickSelectCamera()
            })
        )
        
        self.actionSheet.addAction(UIAlertAction(
            title: "Gallery",
            style: .default,
            handler: { _ in
                self.openImagePicker()
            })
        )
        
        self.actionSheet.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel)
        )
    }
}

extension PhotosGalleryHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        var image: UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = originalImage
        }
        
        if let image = image {
            self.delegate?.onFinishGetImage(selectedImage: image)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
