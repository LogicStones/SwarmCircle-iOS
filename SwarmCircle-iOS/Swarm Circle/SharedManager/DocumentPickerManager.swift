//
//  DocumentPickerManager.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 18/10/2022.
//

import Foundation
import UIKit

class DocumentPickerManager: NSObject {
    
    private var documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.composite-content", "public.jpeg", "public.png", "public.jpg",], in: .import)
    
//    "com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item","public.data", "public.content", "public.audiovisual-content", "public.movie", "public.audiovisual-content", "public.video", "public.audio", "public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content", "public.text"

    private let viewController: UIViewController
    private var pickDocumentURLCallback : ((NSURL) -> ())?
    
    init(_ viewController: UIViewController) {
        
        self.viewController = viewController
        
        self.documentPicker.allowsMultipleSelection = false
        self.documentPicker.shouldShowFileExtensions = true
        self.documentPicker.modalPresentationStyle = .fullScreen
        
        super.init()
        
        self.documentPicker.delegate = self.viewController as? any UIDocumentPickerDelegate
    }
    
//    func pickDocumentURL( _ callback: @escaping ((NSURL) -> ())) {
//
//        self.pickDocumentURLCallback = callback
//
//        self.viewController.present(self.documentPicker, animated: true, completion: nil)
//
//    }
    
    func pickDocument() {
        self.viewController.present(self.documentPicker, animated: true, completion: nil)
    }
}

//extension DocumentPickerManager: UIDocumentPickerDelegate {
//
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
////        self.pickDocumentURLCallback?(urls.first! as NSURL)
//    }
//}
