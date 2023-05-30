//
//  LoginViewController.swift
//  FlowerGarden
//
//  Created by 심두용 on 2022/09/17.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: GIDSignInButton!
    
    static var onwer: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Google Sign in
        GIDSignIn.sharedInstance().presentingViewController = self // 로그인 웹 뷰를 LoginViewController로 열기
        
    }

    @IBAction func emailLoginButtonTapped(_ sender: Any) {
        let emailLoginViewController = storyboard?.instantiateViewController(identifier: "EmailLogin")
    }
    
    @IBAction func googleLoginButtonTapped(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn() // 구글 로그인 화면 열기
        print(LoginViewController.onwer)
    }
}
