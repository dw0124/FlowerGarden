//
//  EmailLoginViewController.swift
//  FlowerGarden
//
//  Created by 심두용 on 2022/09/20.
//

import UIKit
import FirebaseAuth

class EmailLoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.layer.cornerRadius = 8
        signUpButton.layer.cornerRadius = 5
    }
    
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        //Firebase 이메일/비밀번호 인증
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        loginUser(withEamil: email, password: password)
        // 신규 사용자 생성
//        Auth.auth().createUser(withEmail: email, password: password) {[weak self] authResult, error in
//            guard let self = self else { return }
//
//            if let error = error {
//                let code = (error as NSError).code
//                switch code {
//                case 17007: // 이미 가입한 계정일 때
//                    self.loginUser(withEamil: email, password: password)
//                default:
//                    self.errorMessageLabel.text = error.localizedDescription
//                }
//            } else {
//                self.showMainViewController()
//            }
//        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        
        if LoginViewController.onwer {  // 점주 이메일 회원가입
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc = storyboard.instantiateViewController(withIdentifier: "ESignUpOwnerViewController")
            vc.modalPresentationStyle = .fullScreen
            navigationController?.show(vc, sender: nil)
        }
        else {  // 사용자 이메일 회원가입
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc = storyboard.instantiateViewController(withIdentifier: "ESignUpUserViewController")
            vc.modalPresentationStyle = .fullScreen
            navigationController?.show(vc, sender: nil)
        }
        
    }
    
    
    private func loginUser(withEamil email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) {[weak self] _, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessageLabel.text = error.localizedDescription
            } else {
                self.showMainViewController()
            }
        }
    }
    
    private func showMainViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "NavigationController")
        vc.modalPresentationStyle = .fullScreen
        navigationController?.show(vc, sender: nil)
    }
}

extension EmailLoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let isEmailEmpty = emailTextField.text == ""
        let isPasswordEmpty = passwordTextField.text == ""
        loginButton.isEnabled = !isEmailEmpty && !isPasswordEmpty
    }
}
