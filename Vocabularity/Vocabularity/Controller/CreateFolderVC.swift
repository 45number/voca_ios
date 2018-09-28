//
//  CreateFolder.swift
//  Vocabularity
//
//  Created by Admin on 26.09.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit
import CropViewController

class CreateFolderVC: UIViewController
//    , UITextFieldDelegate
//, CropViewControllerDelegate
{

    //Outlets
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var folderImgBtn: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var folderImg: CircleImage!
    
    //Variables
    var imagePicker = UIImagePickerController()
    private var image: UIImage?
    private var croppingStyle = CropViewCroppingStyle.circular
    
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
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
}

extension CreateFolderVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
////            folderImg.image = image
//
////            let cropViewController = CropViewController(image: image)
////            cropViewController.delegate = self
////            present(cropViewController, animated: true, completion: nil)
//
//
//        }
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
        let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
        cropController.delegate = self
        self.image = image
        picker.pushViewController(cropController, animated: true)
        
//        dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
        folderImg.image = image
        dismiss(animated: true, completion: nil)
    }
    
}
