//
//  IDPicturePageContentVC.swift
//  safetyApp
//
//  Created by Amy Xiong on 7/12/16.
//  Copyright © 2016 Stephanie Angulo. All rights reserved.
//

import UIKit
import ParseUI

protocol IDPicturePageContentDelegate: class {
    func setPicture(index: Int, picture: PFFile)
}

class IDPicturePageContentVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var addNewPhotoView: UIView!
    @IBOutlet weak var pictureView: PFImageView!
    
    weak var delegate: IDPicturePageContentDelegate?
    
    var dismissCompletion: (() -> ())!
    
    var showAddNewPhoto: Bool = false
    var pageIndex: Int!
    var picture: PFFile?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let pic = picture {
            pictureView.file = pic
            pictureView.loadInBackground()
        }
        
        addNewPhotoView.hidden = !showAddNewPhoto
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapAddNew(sender: AnyObject) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        vc.modalPresentationStyle = .OverFullScreen
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func didTapPicture(sender: AnyObject) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        vc.modalPresentationStyle = .OverFullScreen
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Get the image captured by the UIImagePickerController
        let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        let imagePFFile = getPFFileFromImage(editedImage)
        
        var error = false
        
        if let image = imagePFFile {
            // Display image and hide "add new"
            self.pictureView.image = editedImage
            self.picture = image
            if showAddNewPhoto {
                addNewPhotoView.hidden = true
            }
            
            delegate?.setPicture(pageIndex, picture: image)
        } else {
            error = true
        }
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismissViewControllerAnimated(true, completion: {
            self.dismissCompletion()
            if error {
                showBasicAlert(self, title: "Error", message: "There was an error choosing the image.")
            }
        })
    }
}
