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
    
    
    //Functions
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}

extension CreateFolderVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
        let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
        cropController.delegate = self
        self.image = image
        picker.pushViewController(cropController, animated: true)
        
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
        
        let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 256.0, height: 256.0))
//        resizeImage(UIImage(named: image)!, targetSize: CGSizeMake(200.0, 200.0))
        folderImg.image = resizedImage
        dismiss(animated: true, completion: nil)
    }
    
}
