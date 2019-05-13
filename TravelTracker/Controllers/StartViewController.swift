//
//  StartViewController.swift
//  TravelTracker
//
//  Created by Gabriel Blaine Palmer on 3/26/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonsView.isHidden = true
        loadingIndicator.color = UIColor.black

        FirebaseController.shared.signInSavedUser { (success) in
            DispatchQueue.main.async {
                if success {
                    self.performSegue(withIdentifier: "autoSignInSegue", sender: nil)
                } else {
                    self.buttonsView.isHidden = false
                }
            }
        }
        
        buttonsView.isHidden = true
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        
        switch sender.tag {
        case 0:
            performSegue(withIdentifier: "signUpSegue", sender: nil)
        case 1:
            performSegue(withIdentifier: "signInSegue", sender: nil)
        default:
            print("\nUnkown segue indentifier in start view controller\n")
        }
        
    }

    @IBAction func unwindFromSettings(sender: UIStoryboardSegue) {
        FirebaseController.shared.signOutSavedUser()
        FirebaseController.shared.friends.removeAll()
        FirebaseController.shared.friendUsernames.removeAll()
        FirebaseController.shared.friendRequests.removeAll()
        FirebaseController.shared.sentRequests.removeAll()
        FirebaseController.shared.currentUser = nil
        loadingIndicator.isHidden = true
        buttonsView.isHidden = false
        
    }
    
    
}
