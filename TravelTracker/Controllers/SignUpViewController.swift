//
//  SignUpViewController.swift
//  TravelTracker
//
//  Created by Gabriel Blaine Palmer on 3/26/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit
import Network

class SignUpViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    let monitor = NWPathMonitor()
    
    var validTextFields: [Bool] = [false, false, false, false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        confirmTextField.delegate = self
        
        createButton.setBackgroundColor(UIColor.lightGray, for: .disabled)
        createButton.isEnabled = false
        errorLabel.isHidden = true
        
        monitor.pathUpdateHandler = { path in
            print("network connection changed")
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self.errorLabel.isHidden = true
                } else {
                    self.createButton.isEnabled = false
                    self.errorLabel.text = "No internet connection"
                    self.errorLabel.isHidden = false
                }
            }
        }
        
        let queue = DispatchQueue(label: "signUpMonitor")
        monitor.start(queue: queue)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    //===========================================
    // MARK: - Text Field Delegate
    //===========================================
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        print("textFieldShouldReturn called")
        
        if nameTextField.isFirstResponder {
            userNameTextField.becomeFirstResponder()
        } else if userNameTextField.isFirstResponder {
            
            if let text = userNameTextField.text, text.count < 5 {
                userNameTextField.resignFirstResponder()
                errorLabel.text = "Username must be at least five characters"
                errorLabel.isHidden = false
                return true
            }
            
            passwordTextField.becomeFirstResponder()
        } else if passwordTextField.isFirstResponder {
            
            if let text = passwordTextField.text, text.count < 5 {
                passwordTextField.resignFirstResponder()
                errorLabel.text = "Password must be at least five characters"
                errorLabel.isHidden = false
                return true
            }
            
            confirmTextField.becomeFirstResponder()
        } else if confirmTextField.isFirstResponder {
            confirmTextField.resignFirstResponder()
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        switch textField {
        case nameTextField:
            if let text = nameTextField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty {
                validTextFields[0] = true
            } else {
                validTextFields[0] = false
            }
            
        case userNameTextField:
            if let text = userNameTextField.text, text.count >= 5 {
                validTextFields[1] = true
            } else {
                validTextFields[1] = false
            }
            
        case passwordTextField:
            if let text = passwordTextField.text, text.count >= 5 {
                validTextFields[2] = true
            } else {
                validTextFields[2] = false
            }
            
        case confirmTextField:
            if let text = confirmTextField.text, text.count >= 5 {
                validTextFields[3] = true
            } else {
                validTextFields[3] = false
            }
        default:
            print("text field switch statment does not include this text field")
        }
        
        createButton.isEnabled = !validTextFields.contains(false)
        
        if textField == nameTextField {
            let invalidCharacters = CharacterSet(charactersIn: "0123456789qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM ").inverted
            return string.rangeOfCharacter(from: invalidCharacters) == nil
        } else {
            let invalidCharacters = CharacterSet(charactersIn: "_0123456789qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM").inverted
            return string.rangeOfCharacter(from: invalidCharacters) == nil
        }
    }
    
    @IBAction func createButtonTapped(_ sender: Any) {
        guard let name = nameTextField.text, name.trimmingCharacters(in: .whitespaces).count > 0 else {
            createButton.isEnabled = false
            errorLabel.text = "Name is invalid"
            errorLabel.isHidden = false
            return
        }
        
        guard let username = userNameTextField.text, username.trimmingCharacters(in: .whitespaces).count >= 5 else {
            createButton.isEnabled = false
            errorLabel.text = "Username must be at least five characters"
            errorLabel.isHidden = false
            return
        }
        
        guard let password = passwordTextField.text, password.trimmingCharacters(in: .whitespaces).count >= 5 else {
            createButton.isEnabled = false
            errorLabel.text = "Password must be at least five characters"
            errorLabel.isHidden = false
            return
        }
        
        guard let confirmText = confirmTextField.text, password == confirmText else {
            createButton.isEnabled = false
            errorLabel.text = "Passwords do not match"
            errorLabel.isHidden = false
            return
        }
        
        guard username != password else {
            createButton.isEnabled = false
            errorLabel.text = "Username and password cannot be the same"
            errorLabel.isHidden = false
            return
        }
        
        FirebaseController.createUser(name: name, username: username, password: password) { (success) in
            
        }
        
    }
    
}
