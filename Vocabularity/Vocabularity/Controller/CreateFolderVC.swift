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
    @IBOutlet weak var titleLbl: UILabel!
    
    
    
    
    //Variables
    var imagePicker = UIImagePickerController()
    var parentFolder: Folder?
    var editingFolder: Folder?
    var learningLanguage: Int?
    private var image: UIImage?
    private var croppingStyle = CropViewCroppingStyle.circular
    private var isImageChanged = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        imagePicker.delegate = self
        
        if editingFolder != nil {
            self.initializeEditingViews()
        }
        
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
            
            if editingFolder != nil {
                imageName = (editingFolder?.image)!
            }
            
            if isImageChanged {
                if editingFolder == nil && editingFolder?.image != "default.png" && editingFolder?.image != nil {
                    ImageStore.delete(imageNamed: (editingFolder?.image)!)
                }
                
                do {
                    imageName = ImageStore.generateImageName(length: 10)
                    try ImageStore.store(image: self.image!, name: imageName)
                } catch let error {
                    debugPrint(error as Any)
                }
            }
            
            self.save(learningLanguage: self.learningLanguage!, folderName: textField.text!, imageName: imageName) { (success) in
                if success {
                    dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func folderImgBtnPressed(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    //Functions
    func save(learningLanguage: Int,folderName: String, imageName: String, completion: (_ finished: Bool) -> ()) {
//        UIApplication.shared.delegate?.persistent
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        

        if editingFolder == nil {
            
            let newFolder = Folder(context: managedContext)
            newFolder.learningLang = Int32(learningLanguage)
            newFolder.folderName = folderName.trimmingCharacters(in: .whitespacesAndNewlines)
            newFolder.image = imageName
            newFolder.marked = false
            newFolder.parent = self.parentFolder
            
        } else {
            
            self.editingFolder?.folderName = folderName
            self.editingFolder?.image = imageName
            
        }
        
        
//        print(newFolder.learningLang)
        
        do {
            try managedContext.save()
            NotificationCenter.default.post(name: NOTIF_WORDS_COUNT_DID_CHANGE, object: nil)
            print("Successfully saved data.")
            completion(true)
        } catch {
            debugPrint("Could not save: \(error.localizedDescription)")
            completion(false)
        }
        
    }
    
    func initializeEditingViews() {
//        folderImg
        if editingFolder != nil {
            self.titleLbl.text = STRING_EDIT_FOLDER
        }
        
        textField.text = editingFolder?.folderName
        if editingFolder?.image == "default.png" {
            self.folderImgBtn.setTitle(STRING_ADD_IMAGE, for: .normal)
        }
        if editingFolder?.image != "default.png" && editingFolder?.image != nil {
            let folderImage = ImageStore.retrieve(imageNamed: (editingFolder?.image)!)
            self.folderImg.image = folderImage
            self.folderImgBtn.setTitle(STRING_CHANGE_IMAGE, for: .normal)
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
