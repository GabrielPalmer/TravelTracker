//
//  StartViewController.swift
//  TravelTracker
//
//  Created by Gabriel Blaine Palmer on 3/26/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit
import FirebaseFirestore

class StartViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        Firestore.firestore().collection("users").document("bombtastical").collection("markers").document(UUID().uuidString).setData([
//            "comment" : "Test Comment 4",
//            "date" : Timestamp(date: Date()),
//            "xCoord" : 35.7612,
//            "yCoord" : 42.9769
//            ])
        
        FirebaseController.signInSavedUser { (success) in
            DispatchQueue.main.async {
                if success {
                    self.performSegue(withIdentifier: "autoSignInSegue", sender: nil)
                }
            }

        }
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
    
}
