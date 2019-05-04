//
//  ViewController.swift
//  Uber
//
//  Created by Paul Quinnell on 2019-05-02.
//  Copyright © 2019 Paul Quinnell. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var riderDriverSwitch: UISwitch!
    @IBOutlet weak var topBtn: UIButton!
    @IBOutlet weak var bottomBtn: UIButton!
    @IBOutlet weak var riderLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    
    var signUpMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func topTapped(_ sender: Any) {
        if emailTextField.text == "" || passwordTextField.text == "" {
            displayAlert(title: "Missing Informtion", message: "You must enter a Email and Password")
        } else {
            if let email = emailTextField.text{
                if let password = passwordTextField.text {
            if signUpMode {
                // SIGNUP
                Auth.auth().createUser(withEmail: email, password: password, completion: {(user, error) in
                    if error != nil {
                        self.displayAlert(title: "Error", message: error!.localizedDescription)
                    } else {
                        if self.riderDriverSwitch.isOn{
                            // DRIVER
                            self.performSegue(withIdentifier: "driverSegue", sender: nil)
                            let ref = Auth.auth().currentUser?.createProfileChangeRequest()
                            ref?.displayName = "Driver"
                            ref?.commitChanges(completion: nil)
                        } else {
                            // RIDER
                            self.performSegue(withIdentifier: "riderSegue", sender: nil)
                            let ref = Auth.auth().currentUser?.createProfileChangeRequest()
                            ref?.displayName = "Rider"
                            ref?.commitChanges(completion: nil)
                        }
                        

                    }
                })
            }else{
                // LOGIN
                Auth.auth().signIn(withEmail: email, password: password, completion: {(user, error) in
                    if error != nil {
                        self.displayAlert(title: "Error", message: error!.localizedDescription)
                    } else {
                        if user?.user.displayName == "Driver" {
                            //Driver
                            self.performSegue(withIdentifier: "driverSegue", sender: nil)

                        } else {
                            //Rider
                            self.performSegue(withIdentifier: "riderSegue", sender: nil)
                        }
                    }
                })
            }
                }}
        }
    }
    
    func displayAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func bottomTapped(_ sender: Any) {
        if signUpMode {
            topBtn.setTitle("Log In", for: .normal)
            bottomBtn.setTitle("Switch to Sign Up", for: .normal)
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            riderDriverSwitch.isHidden = true
            signUpMode = false
        } else {
            topBtn.setTitle("Sign Up", for: .normal)
            bottomBtn.setTitle("Switch to Login", for: .normal)
            riderLabel.isHidden = false
            driverLabel.isHidden = false
            riderDriverSwitch.isHidden = false
            signUpMode = true
        }
    }
    
}

