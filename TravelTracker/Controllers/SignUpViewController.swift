//
//  SignUpViewController.swift
//  TravelTracker
//
//  Created by Gabriel Blaine Palmer on 3/26/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit
import FirebaseCore

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        confirmTextField.delegate = self
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    //===========================================
    // MARK: - Text Field Delegate
    //===========================================
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if nameTextField.isFirstResponder {
            userNameTextField.becomeFirstResponder()
        } else if userNameTextField.isFirstResponder {
            passwordTextField.becomeFirstResponder()
        } else if passwordTextField.isFirstResponder {
            confirmTextField.becomeFirstResponder()
        } else if confirmTextField.isFirstResponder {
            confirmTextField.resignFirstResponder()
        }
        
        return true
    }
    

}
