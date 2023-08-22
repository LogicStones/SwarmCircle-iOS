//
//  ImagePickerManager.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 09/09/2022.
//

import Foundation
import UIKit

class ImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var picker = UIImagePickerController();
    var alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
    var viewController: UIViewController?
    var pickImageCallback : ((UIImage) -> ())?;
    var pickImageURLCallback : ((NSURL) -> ())?;
    
    override init() {
        
        super.init()
        let cameraAction = UIAlertAction(title: "Camera", style: .default) {
            UIAlertAction in
            self.openCamera()
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) {
            UIAlertAction in
            self.openGallery()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            UIAlertAction in
        }
        
        // Add the actions
        picker.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(galleryAction)
        alert.addAction(cancelAction)
    }
    
    func pickImage(_ viewController: UIViewController, _ callback: @escaping ((UIImage) -> ())) {
        pickImageCallback = callback;
        self.viewController = viewController;
        
        alert.popoverPresentationController?.sourceView = self.viewController!.view
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Picks image URL
    func pickImageURL(_ viewController: UIViewController, _ callback: @escaping ((NSURL) -> ())) {
        
        self.pickImageURLCallback = callback;
        self.viewController = viewController;
        
        alert.popoverPresentationController?.sourceView = self.viewController!.view
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(){
        alert.dismiss(animated: true, completion: nil)
        if(UIImagePickerController .isSourceTypeAvailable(.camera)) {
            picker.sourceType = .camera
            picker.allowsEditing = true
            self.viewController!.present(picker, animated: true, completion: nil)
        } else {
            let alertController: UIAlertController = {
                let controller = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                controller.addAction(action)
                return controller
            }()
            viewController?.present(alertController, animated: true)
        }
    }
    
    func openGallery(){
        alert.dismiss(animated: true, completion: nil)
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.viewController!.present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    //for swift below 4.2
    //func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    //    picker.dismiss(animated: true, completion: nil)
    //    let image = info[UIImagePickerControllerOriginalImage] as! UIImage
    //    pickImageCallback?(image)
    //}
    
    // For Swift 4.2+
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if self.pickImageURLCallback != nil {
            //            PHPickerViewController.refere
            guard let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? NSURL else {
                fatalError("Expected a dictionary containing an image URL, but was provided the following: \(info)")
            }
            
            self.pickImageURLCallback?(imageURL)
            
        } else if self.pickImageCallback != nil {
            guard let image = info[.editedImage] as? UIImage else {
                fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
            }
            pickImageCallback?(image)
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
    }
    
}
