//
//  LoginViewController.swift
//  try2.0
//
//  Created by Claire Sagalow on 27/12/2016.
//  Copyright © 2016 KPS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn
import FBSDKLoginKit
import FBSDKShareKit



class LoginViewController: UIViewController, GIDSignInUIDelegate{
    
    
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var fbButton: UIButton!

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fbButton.addTarget(self, action: #selector(loginFacebook), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(loginGoogle), for: .touchUpInside)
        let user = FIRAuth.auth()?.currentUser
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    func loginFacebook(){
        
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, err) in
            if err != nil{
                print("FB login Fail")
            }
            let accessToken = FBSDKAccessToken.current()
            guard let accessTokenString = accessToken?.tokenString
            else
            {
                print(err!)
                return
            }
            
            let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
            FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
                if error != nil
                {
                    print(error!)
                    if let errCode = FIRAuthErrorCode(rawValue: (error?._code)!) {
                        switch errCode {
                        case .errorCodeEmailAlreadyInUse:
                            let alertController = UIAlertController(title: "Error", message: "Email already used", preferredStyle: .alert)
                            
                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertController.addAction(defaultAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                            return
                        default:

                            return
                        }
                    }
                    
                } else
                {
                    //check existence and creation
                    let ref = FIRDatabase.database().reference(fromURL: "https://howold-b00bc.firebaseio.com/" )
                    let checklist = ref.child("users")
                    let parameter = ["fields": "id, name, email"]
                    let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath:  "me", parameters: parameter)
                        
                    checklist.observeSingleEvent(of: .value, with: { snapshot in
                        
                       
                        
                        graphRequest.start { (connection, result, error) in
                            if error != nil{
                                print("failed to request graph", error!)
                                return
                            }
                            let users = result as? NSDictionary
                            let name = users?.object(forKey: "name")
                            let id = users?.object(forKey: "id")
                            let userName = "f_\(name!)_\(id!)"
                            let userEmail = users?.object(forKey: "email")

                            if snapshot.hasChild("f_\(name!)_\(id!)")
                            {
                                return
                            }
                            else // create if didn't exist
                            {
                                _ = ref.child("users").child(userName ).setValue(["Name": name, "Email":userEmail,"Score" : 0, "Photos" : 0,  "From" : "Facebook"])
                            }
                            
                        }
                    })
                
                    let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "Game") as UIViewController
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
                    appDelegate.window?.rootViewController = initialViewControlleripad
                    appDelegate.window?.makeKeyAndVisible()
                }
            })

        }
    }
    
    func loginGoogle()
    {
        GIDSignIn.sharedInstance().signIn()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    
    @IBAction func Login(_ sender: Any) {
        
        if usernameTextField.text == "" || passwordTextField.text == "" {
            
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields because they didn't fill anything in
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            FIRAuth.auth()?.signIn(withEmail: usernameTextField.text!, password: passwordTextField.text!) { (user, error) in
                
                if error != nil
                {
                    
                    //Tells the user that there is an error and then gets firebase to tell them the error
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)

                    
                }
                //Print into the console if successfully logged in
                print("You have successfully logged in")
                //Go to the HomeViewController if the login is sucessful
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Game")
                self.present(vc!, animated: true, completion: nil)
            }
        }
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
