//
//  StartViewController.swift
//  TravelTracker
//
//  Created by Gabriel Blaine Palmer on 3/26/19.
//  Copyright © 2019 Gabriel Blaine Palmer. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //check connection for auto sign in
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
