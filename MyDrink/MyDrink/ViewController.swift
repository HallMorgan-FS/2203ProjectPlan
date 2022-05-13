//
//  ViewController.swift
//  MyDrink
//
//  Created by Morgan Hall on 5/5/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController, UITextFieldDelegate {
    
    //Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //properties
    var emailAddress = ""
    var passWord = ""
    var userID = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        emailTextField.delegate = self
        emailTextField.returnKeyType = .done
        passwordTextField.delegate = self
        passwordTextField.returnKeyType = .done
        
    }
    
    //Button Actions
    @IBAction func forgotPasswordClicked(_ sender: UIButton) {
    }
    
    
    @IBAction func newAccountTapped(_ sender: UIButton) {
        
        //Show alert that lets the user know we can create an account for them if they enter an email and password
        
        //Create alert
        let alert = UIAlertController(title: "New User?", message: "Enter a valid email and password in the appropriate fields and we will create an account for you when you tap 'Sign in with email'!", preferredStyle: .alert)
        //Create action
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        //Add action to the alert
        alert.addAction(action)
        
        //Present alert
        present(alert, animated: true, completion: nil)
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @IBAction func emailSignInTapped(_ sender: UIButton) {
        
        //Validate the text fields are not empty
        if emailTextField.text == nil || passwordTextField.text == nil {
            
            showMessagePrompt(title: "Error", message: "Email and password fields cannot be left blank. Please try again.", action: "Try Again")
        } else {
            if let vEmail = emailTextField.text,
               let vPassword = passwordTextField.text {
                
                //Verify login information
                CheckAuth(email: vEmail, password: vPassword)
            }
        }
        
        
    }
    
    func CheckAuth(email: String, password: String) {
        
        emailAddress = email
        passWord = password
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else {return}
            
            if error != nil {
                let authError = error as! AuthErrorCode
                if authError.code == AuthErrorCode.wrongPassword {
                    //Show wrong credentials alert
                    strongSelf.showMessagePrompt(title: "Wrong Password", message: "That password is incorrect. Please try again.", action: "Try Again")
                    strongSelf.clearFields()
                }
                else if authError.code == AuthErrorCode.invalidEmail {
                    //Show invalid email alert
                    strongSelf.showMessagePrompt(title: "Invalid Email", message: "The email entered is invalid. Please try again", action: "Try Again")
                }
                else if authError.code == AuthErrorCode.userNotFound {
                    //Show account creation alert if the user is not found
                    strongSelf.showAccountCreation()
                }
                
                
            } else {
                print("You have signed in")
                strongSelf.emailAddress = email
                strongSelf.passWord = password
                //If successful, navigate to homepage.
                strongSelf.signInSuccess()
            }
            
            
        }
        
    }
    
    //Function to create an account with an alert
    func showAccountCreation() {
        
        //Create alert
        let alert = UIAlertController(title: "Create Account?", message: "The email/password entered wasn't recognized. Would you like to try again or create an account using the email and password given?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Create Account", style: .default, handler: { _ in
            //Create an account with the email/password
            self.createAccount()
            
        })
        let dismiss = UIAlertAction(title: "Try Again", style: .cancel, handler: nil)
        alert.addAction(action) ; alert.addAction(dismiss)
        present(alert, animated: true, completion: nil)
    }
    
    func createAccount() {
        //Create the account
        Auth.auth().createUser(withEmail: self.emailAddress, password: self.passWord) { [weak self] authResut, error in
            //Make sure there are no errors
            guard let strongSelf = self else {return}
            
            if error != nil {
                let authError = error as! AuthErrorCode
                
                print("Account creation failed. The Error: \(authError)")
                strongSelf.showMessagePrompt(title: "Error", message: authError.localizedDescription, action: "Try Again")
                return
            }
            
            //Get a unique user id
            guard let uid = authResut?.user.uid else {return}
            
            let values = ["email": strongSelf.emailAddress]
            
            //Create database reference
            Database.database().reference().child("users").child(uid).updateChildValues(values) { error, ref in
                print("Failed to store to database.", error?.localizedDescription as Any)
            }
            
            //Store the user ID
            strongSelf.userID = uid
            
            //Show successful account creation alert
            strongSelf.showMessagePrompt(title: "Success!", message: "You have successfully created a My Drink account!", action: "OK")
            
            //Clear fields
            strongSelf.clearFields()
            //Navigate to next view
            strongSelf.signInSuccess()
        }
    }
    
    //Function to create one alert with one action
    func showMessagePrompt(title: String, message: String, action: String) {
        
        //Create alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: action, style: .default, handler: nil))
        //present alert
        present(alert, animated: true, completion: nil)
        
    }
    
    func clearFields() {
        emailTextField.text = nil
        passwordTextField.text = nil
        emailAddress = ""
        passWord = ""
    }
    
    @IBAction func appleSignInTapped(_ sender: UIButton) {
    }
    
    
    @IBAction func googleSignInTapped(_ sender: UIButton) {
    }
    
    //Function for a successful sign in
    func signInSuccess() {
        //save userinfo to UserData
        //navigate to next view
        performSegue(withIdentifier: "toMyPlaces", sender: self)
    }
    //MARK: - Sign in completion is not going to next page.. Figure out why
    /* Change the root view controller and the segue to the added places screen.
     The SIGN IN WORKS AMAZAZING! */
    
    //Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMyPlaces" {
            guard let destination = segue.destination as? MyPlacesVC else {return}
            
            //Send user info to next page
            destination.userID = userID
        }
    }
    

}

