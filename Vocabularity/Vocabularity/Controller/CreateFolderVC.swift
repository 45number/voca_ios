//
//  CreateFolder.swift
//  Vocabularity
//
//  Created by Admin on 26.09.2018.
//  Copyright © 2018 vocabularity. All rights reserved.
//

import UIKit
import CoreData
import CropViewController

class CreateFolderVC: UIViewController, UITextFieldDelegate {

    //Outlets
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var folderImgBtn: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var folderImg: CircleImage!
    @IBOutlet weak var tempImage: UIImageView!
    
    //Variables
    var imagePicker = UIImagePickerController()
    var parentFolder: Folder?
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
            var imageName = "default.png"
            if isImageChanged {
                do {
                    imageName = ImageStore.generateImageName(length: 10)
                    try ImageStore.store(image: self.image!, name: imageName)
                } catch let error {
                    debugPrint(error as Any)
                }
                
//                let tempImg = ImageStore.retrieve(imageNamed: imageName)
//                textField.text = imageName
//                self.tempImage.image = tempImg
            }
            
            
            self.save(folderName: textField.text!, imageName: imageName) { (success) in
                if success {
                    dismiss(animated: true, completion: nil)
                }
            }
//            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func folderImgBtnPressed(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    //Functions
    func save(folderName: String, imageName: String, completion: (_ finished: Bool) -> ()) {
//        UIApplication.shared.delegate?.persistent
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
        let newFolder = Folder(context: managedContext)
        newFolder.folderName = folderName
        newFolder.image = imageName
        newFolder.learningLanguage = Int32(1)
        newFolder.parent = self.parentFolder
        
        do {
            try managedContext.save()
            print("Successfully saved data.")
            completion(true)
        } catch {
            debugPrint("Could not save: \(error.localizedDescription)")
            completion(false)
        }
        
    }
    
}

extension CreateFolderVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
        let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
        cropController.delegate = self
        
        picker.pushViewController(cropController, animated: true)
        
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
        
        let resizedImage = ImageStore.resizeImage(image: image, targetSize: CGSize(width: 256.0, height: 256.0))
//        resizeImage(UIImage(named: image)!, targetSize: CGSizeMake(200.0, 200.0))
        folderImg.image = resizedImage
        self.image = resizedImage
        isImageChanged = true
        
//        let imageName = ImageStore.generateImageName(length: 10)
        
        dismiss(animated: true, completion: nil)
    }
    
}
