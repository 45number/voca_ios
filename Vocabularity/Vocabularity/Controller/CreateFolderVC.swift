//
//  CreateFolder.swift
//  Vocabularity
//
//  Created by Admin on 26.09.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit
import CropViewController

class CreateFolderVC: UIViewController, UITextFieldDelegate {

    //Outlets
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var folderImgBtn: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var folderImg: CircleImage!
    
    //Variables
    var imagePicker = UIImagePickerController()
    private var image: UIImage?
    private var croppingStyle = CropViewCroppingStyle.circular
    private var isImageChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
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
        if textField.text != "" {
            if isImageChanged {
                do {
                    try ImageStore.store(image: self.image!, name: "imodj")
                } catch let error {
                    debugPrint(error as Any)
                }
                
            }
            dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func folderImgBtnPressed(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    //Functions
    
    
}

extension CreateFolderVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
        let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
        cropController.delegate = self
        
        picker.pushViewController(cropController, animated: true)
        
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
        
        let resizedImage = ImageStore.resizeImage(image: image, targetSize: CGSize(width: 256.0, height: 256.0))
//        resizeImage(UIImage(named: image)!, targetSize: CGSizeMake(200.0, 200.0))
        folderImg.image = resizedImage
        self.image = resizedImage
        isImageChanged = true
        dismiss(animated: true, completion: nil)
    }
    
}
