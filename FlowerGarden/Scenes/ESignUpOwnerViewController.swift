//
//  ESignUpOwnerViewController.swift
//  FlowerGarden
//
//  Created by 심두용 on 2022/09/27.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

// MARK: - ZipcodeDelegate
protocol ZipcodeDelegate{
    func sendZipcode(data: Addresses)
}

// MARK: - ESignUpOwnerViewController
class ESignUpOwnerViewController: UIViewController{

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var storeNameTextField: UITextField!
    @IBOutlet weak var storeAddressTextField: UITextField!
    @IBOutlet weak var storeNumberTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var completionButton: UIButton!
    var zipcode: String?
    var storeX: String?
    var storeY: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        completionButton.layer.cornerRadius = 5
    }
    
    @IBAction func comepletionButtonTapped(_ sender: Any) {
        //신규 사용자 생성
       Auth.auth().createUser(withEmail: emailTextField.text ?? "", password: passwordTextField.text ?? "") {[weak self] authResult, error in
           guard let self = self else { return }

           if let error = error {
               let code = (error as NSError).code
               switch code {
               case 17007: // 이미 가입한 계정일 때
                   //self.loginUser(withEamil: email, password: password)
                   self.errorMessageLabel.text = error.localizedDescription
               default:
                   self.errorMessageLabel.text = error.localizedDescription
               }
           } else {
               // 회원가입하면 자동으로 로그인 -> 로그인된 uid 추출
               let user = Auth.auth().currentUser
               // Real Database에 회원 저장
               var ref: DatabaseReference!
               ref = Database.database().reference()
               ref.child("owner_list").child(user?.uid ?? "uid")
                   .setValue(["uid": user?.uid,
                              "name": self.nameTextField.text,
                              "email": self.emailTextField.text,
                              "store_name": self.storeNameTextField.text,
                              "store_address": self.storeAddressTextField.text,
                              "store_number" : self.storeNumberTextField.text,
                              "x": self.storeX,
                              "y": self.storeY])
               self.showLoginViewController()
           }
       }
    }
    
    private func showLoginViewController() {
        
        guard let ownerImageVC = self.storyboard?.instantiateViewController(withIdentifier: "owenrImage") as? OwnerImageViewController else { return }
        
        if let ownerStoreName = storeNameTextField.text {
            ownerImageVC.ownerStoreName = ownerStoreName
        }
        
        self.navigationController?.pushViewController(ownerImageVC, animated: true)
    
    }
}



extension ESignUpOwnerViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func tapZipcode(){
        guard let kakaoVC = self.storyboard?.instantiateViewController(withIdentifier: "Kakaozipcode") as? KakaoZipCodeVC else {return}
        kakaoVC.delegate = self
        
        self.present(kakaoVC, animated: true, completion: nil)
    }
}

extension ESignUpOwnerViewController: ZipcodeDelegate {
    
    func sendZipcode(data: Addresses) {
        print("zipcode!")
        
        if data.addresses.isEmpty { return }
        
        zipcode = data.addresses[0].roadAddress
        storeX = data.addresses[0].x
        storeY = data.addresses[0].y
        DispatchQueue.main.async {
            self.storeAddressTextField.text = self.zipcode
        }
    }
    
}
