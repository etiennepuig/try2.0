//
//  SignUpController.swift
//  try2.0
//
//  Created by Brian on 21/12/2016.
//  Copyright © 2016 KPS. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseAuth

class SignUpController: UIViewController {
    
    
    @IBOutlet weak var usernameSignUp: UITextField!
    @IBOutlet weak var mailSignUp: UITextField!
    @IBOutlet weak var passwordSignUp: UITextField!
    
    var context:NSManagedObjectContext?
    
    @IBAction func signUpButton(_ sender: UIButton) {
            
            if mailSignUp.text == "" {
                let alertController = UIAlertController(title: "Error", message: "Please enter your email and password", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                present(alertController, animated: true, completion: nil)
                
            } else {
                FIRAuth.auth()?.createUser(withEmail: mailSignUp.text!, password: passwordSignUp.text!) { (user, error) in
                    
                    if error == nil {
                        print("You have successfully signed up")
                        //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username
                        
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Game")
                        self.present(vc!, animated: true, completion: nil)
                        
                    } else {
                        let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertController.addAction(defaultAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
