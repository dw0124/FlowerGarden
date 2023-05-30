//
//  testViewController.swift
//  FlowerGarden
//
//  Created by 김두원 on 2022/11/08.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseFirestore

class OwnerImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    var ownerStoreName: String = "꽃병"
    let storage = Storage.storage()
    lazy var imagePicker: UIImagePickerController = {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(ownerStoreName)
        
    }
    
    @IBAction func completionButton(){
            self.navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func uploadButton() {
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    // ownerStoreName을 넘겨받았느지 확인해야할듯
    func uploadimage(img :UIImage){
        guard let data = img.jpegData(compressionQuality: 0.8) else { return }
        // filePath: image파일 이름
        let filePath = ownerStoreName
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        storage.reference().child(filePath).putData(data,metadata: metaData){
            (metaData,error) in if let error = error{
                print(error.localizedDescription)
                return
            }else{
                print("성공")
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let originalImage: UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = originalImage
            imageView.contentMode = .scaleAspectFill
            uploadimage(img: originalImage)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}


