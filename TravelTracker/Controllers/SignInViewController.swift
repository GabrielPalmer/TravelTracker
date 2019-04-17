//
//  SignInViewController.swift
//  TravelTracker
//
//  Created by Gabriel Blaine Palmer on 3/26/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit
import Network

class SignInViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    let monitor = NWPathMonitor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        
        signInButton.setBackgroundColor(UIColor.lightGray, for: .disabled)
        /// Change back isEnabled to false
        signInButton.isEnabled = true
        errorLabel.isHidden = true
        
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self.errorLabel.isHidden = true
                } else {
                    self.signInButton.isEnabled = false
                    self.errorLabel.text = "No internet connection"
                    self.errorLabel.isHidden = false
                }
            }
        }
        
        let queue = DispatchQueue(label: "signInMonitor")
        monitor.start(queue: queue)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if userNameTextField.isFirstResponder {
            passwordTextField.becomeFirstResponder()
        } else if passwordTextField.isFirstResponder {
            passwordTextField.resignFirstResponder()
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        signInButton.isEnabled = !userNameTextField.text!.isEmpty && !passwordTextField.text!.isEmpty
        
            if let text = passwordTextField.text {
              signInButton.isEnabled = text.count >= 5
            }
        
        let invalidCharacters = CharacterSet(charactersIn: "_0123456789qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM").inverted
        return string.rangeOfCharacter(from: invalidCharacters) == nil
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        
        guard let username = userNameTextField.text, !username.trimmingCharacters(in: .whitespaces).isEmpty else {
            signInButton.isEnabled = false
            errorLabel.text = "Username must be at least five characters"
            errorLabel.isHidden = false
            return
        }
        
        guard let password = passwordTextField.text, !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            signInButton.isEnabled = false
            errorLabel.text = "Password must be at least five characters"
            errorLabel.isHidden = false
            return
        }
        
        FirebaseController.signIn(username: username, password: password) { (success) in
            
        }
        
    }
    
}
