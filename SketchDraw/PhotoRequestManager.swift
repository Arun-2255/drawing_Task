//
//  PhotoRequestManager.swift
//  SketchDraw
//
//  Created by Arun  on 11/09/24.


import Foundation
import UIKit

enum PhotoRequestResult {
    case success(UIImage)
    case failed(PhotoAuthorizedErrorType)
    case cancel
}

typealias PhotoRequestCompletion = ((PhotoRequestResult) -> Void)

final class PhotoRequestManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    fileprivate static let shared: PhotoRequestManager = PhotoRequestManager()
    fileprivate var completionHandler: (PhotoRequestCompletion)?

    static func requestPhotoLibrary(_ parentViewController: UIViewController, completion: PhotoRequestCompletion?) {
        shared.requestPhoto(parentViewController, sourceType: .photoLibrary, completion: completion)
    }
    
    static func requestPhotoFromCamera(_ parentViewController: UIViewController, completion: PhotoRequestCompletion?) {
        shared.requestPhoto(parentViewController, sourceType: .camera, completion: completion)
    }
    
    static func requestPhotoFromSavedPhotosAlbum(_ parentViewController: UIViewController, completion: PhotoRequestCompletion?) {
        shared.requestPhoto(parentViewController, sourceType: .savedPhotosAlbum, completion: completion)
    }
    
    private func requestPhoto(_ parentViewController: UIViewController, sourceType: UIImagePickerController.SourceType , completion: PhotoRequestCompletion?) {
        if !UIImagePickerController.isSourceTypeAvailable(sourceType) {
            completion?(PhotoRequestResult.failed(.denied))
            return
        }
        
        let resultBlock: PhotoAuthorizedCompletion = { [unowned self] result in
            switch result {
            case .success:
                let imagePickerController : UIImagePickerController = UIImagePickerController()
                imagePickerController.sourceType = sourceType
                imagePickerController.allowsEditing = true
                imagePickerController.delegate = self
                
                self.completionHandler = completion
                
                parentViewController.present(imagePickerController, animated: true, completion: nil)
            case .error(let error):
                completion?(PhotoRequestResult.failed(error))
            }
        }
        
        switch sourceType {
        case .camera:
            PhotoAuthorization.camera(completion: resultBlock)
        case .photoLibrary, .savedPhotosAlbum:
            PhotoAuthorization.photo(completion: resultBlock)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension PhotoRequestManager {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        guard let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage else { return }
        picker.dismiss(animated: true) { [unowned self] in
            self.completionHandler?(PhotoRequestResult.success(image))
            self.completionHandler = nil
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { [unowned self] in
            self.completionHandler?(PhotoRequestResult.cancel)
            self.completionHandler = nil
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
