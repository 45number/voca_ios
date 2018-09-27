//
//  CreateFolder.swift
//  Vocabularity
//
//  Created by Admin on 26.09.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit

class CreateFolderVC: UIViewController
//    , UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate
//, CropViewControllerDelegate
{

    //Outlets
    @IBOutlet weak var buttonsStackView: UIStackView!
//    @IBOutlet weak var folderImg: UIButton!
    @IBOutlet weak var folderImgBtn: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var folderImg: CircleImage!
//    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    
    
    //Variables
    var imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        textField.delegate = self
        imagePicker.delegate = self
        
        
//        textField.becomeFirstResponder()
        buttonsStackView.bindToKeyboard()
    }

    //Actions
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func okBtnPressed(_ sender: Any) {
    }
    @IBAction func folderImgBtnPressed(_ sender: Any) {
        
//        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
//            print("Button capture")
//
//            imagePicker.delegate = self
//            imagePicker.sourceType = .savedPhotosAlbum;
//            imagePicker.allowsEditing = true
//
//            self.present(imagePicker, animated: true, completion: nil)
//        }

        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        
    }
    
//    //Functions
//    @objc func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
//        self.dismiss(animated: true, completion: { () -> Void in
//
//        })
//
//        imageView.image = image
////        folderImg.setImage(image, for: UIControlState.normal)
//    }
    
//    func presentCropViewController(image: UIImage!) {
//
//        let cropViewController = CropViewController(image: image)
//        cropViewController.delegate = self
//        present(cropViewController, animated: true, completion: nil)
//    }
//
//    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
//        // 'image' is the newly cropped version of the original image
//    }

}

extension CreateFolderVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            folderImg.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}
