//
//  ViewController.swift
//  FlatironChat
//
//  Created by Johann Kerr on 3/23/17.
//  Copyright © 2017 Johann Kerr. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController {
    
//    let ref = FIRDatabase.database().reference()
    
    @IBOutlet weak var screenNameField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
       
    }


    @IBAction func joinBtnPressed(_ sender: Any) {
        if let screenName = screenNameField.text {
            anonAuth(userName: screenName)
            UserDefaults.standard.set(screenName, forKey: "screenName")
            self.performSegue(withIdentifier: "openChannel", sender: self)
        }
        
        
    }

    func anonAuth(userName: String) {
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            let isAnonymous = user!.isAnonymous
            let uId = user!.uid
            print(isAnonymous)
            print(uId)
            FIRDatabase.database().reference().child("users").child(userName).setValue(true)
        })

    }
    
  
  
    
}
