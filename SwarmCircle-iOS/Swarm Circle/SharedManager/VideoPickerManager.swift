//
//  VideoPickerManager.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 09/09/2022.
//

import Foundation
import UIKit

class VideoPickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var picker = UIImagePickerController();
    var alert = UIAlertController(title: "Choose Video", message: nil, preferredStyle: .actionSheet)
    var viewController: UIViewController?
    var pickVideoURLCallback : ((NSURL) -> ())?;
    
    override init(){
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

    func pickVideoURL(_ viewController: UIViewController, _ callback: @escaping ((NSURL) -> ())) {
        self.pickVideoURLCallback = callback;
        self.viewController = viewController;

        alert.popoverPresentationController?.sourceView = self.viewController!.view

        viewController.present(alert, animated: true, completion: nil)
    }
    
    func openCamera(){
        alert.dismiss(animated: true, completion: nil)
        if(UIImagePickerController.isSourceTypeAvailable(.camera)){
            picker.mediaTypes = ["public.movie"]
            picker.sourceType = .camera
            picker.cameraCaptureMode = .video
//            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
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
        picker.sourceType = .savedPhotosAlbum
        picker.mediaTypes = ["public.movie"]
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
        guard let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL else {
            fatalError("Expected a dictionary containing a video URL, but was provided the following: \(info)")
        }
        pickVideoURLCallback?(videoURL)
    }



//    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
//    }

}
