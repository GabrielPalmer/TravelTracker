//
//  SignUpViewController.swift
//  TravelTracker
//
//  Created by Gabriel Blaine Palmer on 3/26/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit
import FirebaseCore

class SignUpViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var createButton: UIButton!
    
    var validTextFields: [Bool] = [false, false, false, false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        confirmTextField.delegate = self
        
        createButton.setBackgroundColor(UIColor.lightGray, for: .disabled)
        createButton.isEnabled = false
        
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
        
        print(validTextFields)
        
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
            print("textFieldDidEndEditing switch statment does not include this text field")
        }
        
        createButton.isEnabled = !validTextFields.contains(false)
        
        if textField == nameTextField {
            let invalidCharacters = CharacterSet(charactersIn: "0123456789qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM ").inverted
            return string.rangeOfCharacter(from: invalidCharacters) == nil
        } else {
            let invalidCharacters = CharacterSet(charactersIn: "0123456789qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM").inverted
            return string.rangeOfCharacter(from: invalidCharacters) == nil
        }
    }
    
    @IBAction func createButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "fromUserCreator", sender: nil)
    }
    
}
