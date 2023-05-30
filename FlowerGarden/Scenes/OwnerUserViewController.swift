//
//  OwnerUserViewController.swift
//  FlowerGarden
//
//  Created by 심두용 on 2022/09/22.
//
// test!!!!!!!!???!!??!?

import UIKit

class OwnerUserViewController: UIViewController {

    @IBOutlet weak var userLoginButton: UIButton?
    @IBOutlet weak var ownerLoginButton: UIButton?
    
    var owner: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userLoginButton?.layer.cornerRadius = 25
        ownerLoginButton?.layer.cornerRadius = 25
        // Do any additional setup after loading the view.
    }
    

    @IBAction func ownerButtonTapped(_ sender: Any) {
        owner = true
        performSegue(withIdentifier: "goLogin", sender: sender)
    }
    
    
    @IBAction func userButtonTapped(_ sender: Any) {
        owner = false
        performSegue(withIdentifier: "goLogin", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goLogin" {
            //let vc = segue.destination as! LoginViewController
            LoginViewController.onwer = owner
        }
    }
}
