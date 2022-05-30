//
//  SignInViewController.swift
//  MyDrink
//
//  Created by Morgan Hall on 5/25/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignInViewController: UIViewController {
    
    //Outlets for SIGN IN VIEW
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    
    //properties
    var emailAddress = ""
    var passWord = ""
    var userID = ""
    var signedIn = false
    //Variable to keep track of the sign in button title
    var buttonTitle = "sign in"
    let database = Database.database().reference()
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.isHidden = true
        navigationController?.toolbar.isHidden = true
        signInButton.setTitle("Sign In", for: .normal)
        errorLabel.isHidden = true
        forgotPasswordButton.isHidden = false
        emailTextField.text = ""
        passwordTextField.text = ""
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        signInButton.setTitle("Sign In", for: .normal)
        errorLabel.isHidden = true
        forgotPasswordButton.isHidden = false
        emailTextField.text = nil
        passwordTextField.text = nil
    }
    
    //Button Actions
    @IBAction func forgotPasswordClicked(_ sender: UIButton) {
    }
    
    
    @IBAction func newAccountTapped(_ sender: UIButton) {
        
        //Show alert that lets the user know we can create an account for them if they enter an email and password
        errorLabel.textColor = UIColor.blue
        errorLabel.font = UIFont.boldSystemFont(ofSize: 17)
        errorLabel.text = "Enter a valid email and create a password, then tap CREATE ACCOUNT so we can create for you!"
        errorLabel.isHidden = false
        signInButton.setTitle("CREATE ACCOUNT", for: .normal)
        forgotPasswordButton.isHidden = true
        
    }
    
    @IBAction func emailSignInTapped(_ sender: UIButton) {
        
        //Validate the text fields are not empty
        if emailTextField.text == nil || passwordTextField.text == nil {
            
            errorLabel.text = "Email and password fields cannot be left blank."
            errorLabel.isHidden = false
           
        } else {
            if let vEmail = emailTextField.text,
               let vPassword = passwordTextField.text {
                
                emailAddress = vEmail
                passWord = vPassword
                
            }
            if buttonTitle == "sign in" {
                checkAuth()
            }
            else if buttonTitle == "create account" {
                createAccount()
            }
        }
        
        
    }
    
    func checkAuth() {
        
        Auth.auth().signIn(withEmail: emailAddress, password: passWord) { [weak self] authResult, error in
            guard let strongSelf = self else {return}
            
            if error != nil {
                let authError = error as! AuthErrorCode
                strongSelf.errorLabel.isHidden = false
                if authError.code == AuthErrorCode.wrongPassword {
                    //Show wrong credentials alert
                    strongSelf.errorLabel.text = "The password entered is incorrect. Please try again"
                    
                }
                else if authError.code == AuthErrorCode.invalidEmail {
                    //Show invalid email alert
                    strongSelf.errorLabel.text = "The email entered is invalid. Please try again"
                    
                }
                else if authError.code == AuthErrorCode.userNotFound {
                    //Show alert that lets the user know we can create an account for them if they enter an email and password
                    strongSelf.errorLabel.textColor = UIColor.blue
                    strongSelf.errorLabel.font = UIFont.boldSystemFont(ofSize: 17)
                    strongSelf.errorLabel.text = "Enter a valid email and create a password, then tap CREATE ACCOUNT so we can create for you!"
                    strongSelf.signInButton.setTitle("CREATE ACCOUNT", for: .normal)
                    strongSelf.buttonTitle = "create account"
                    strongSelf.forgotPasswordButton.isHidden = true
                    
                }
                
            } else {
                strongSelf.signedIn = true
                strongSelf.successfulSignIn()
            }
            
        }
        
    }
    
    func createAccount() {
        //Create the account
        Auth.auth().createUser(withEmail: self.emailAddress, password: self.passWord) { [weak self] authResut, error in
            //Make sure there are no errors
            guard let strongSelf = self else {return}
            
            if error != nil {
                let authError = error as! AuthErrorCode
                
                print("Account creation failed. The Error: \(authError)")
                strongSelf.errorLabel.text = "\(authError)"
                strongSelf.errorLabel.isHidden = false
                strongSelf.signedIn = false
            }
            else {
                //Get a unique user id
                guard let uid = authResut?.user.uid else {return}
                
                let values: [String: Any] = ["email": strongSelf.emailAddress]
                
                //Create database reference
                strongSelf.database.child("users").child(uid).updateChildValues(values) { error, ref in
                    print("Failed to store to database.", error?.localizedDescription as Any)
                }
                
                strongSelf.defaults.setValue(uid, forKey: "uid")
                
                //Store the user ID
                strongSelf.userID = uid
                
                strongSelf.signedIn = true
            }
            //Check sign in
            strongSelf.successfulSignIn()
            
        }
    }
    
    //Function for if sign in is successful
    func successfulSignIn() {
        if signedIn {
            performSegue(withIdentifier: "toMyPlaces", sender: self)
        } else {
            emailTextField.text = nil
            passwordTextField.text = nil
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return signedIn
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if let destination = segue.destination as? MyPlacesVC {
            // Pass the selected object to the new view controller.
            destination.userID = self.userID
            destination.database = self.database
        }
        
    }
    

}
