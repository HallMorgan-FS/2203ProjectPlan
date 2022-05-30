//
//  SignIn.swift
//  MyDrink
//
//  Created by Morgan Hall on 5/16/22.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignIn {
    
    var email: String
    var  password: String
    var signedIn: Bool = false
    var userID: String = ""
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    func checkAuth() {
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else {return}
            
            if error != nil {
                let authError = error as! AuthErrorCode
                if authError.code == AuthErrorCode.wrongPassword {
                    //Show wrong credentials alert
                    strongSelf.showMessagePrompt(title: "Wrong Password", message: "That password is incorrect. Please try again.", action: "Try Again", view: MyPlacesVC())
                    
                }
                else if authError.code == AuthErrorCode.invalidEmail {
                    //Show invalid email alert
                    strongSelf.showMessagePrompt(title: "Invalid Email", message: "The email entered is invalid. Please try again", action: "Try Again", view: MyPlacesVC())
                }
                else if authError.code == AuthErrorCode.userNotFound {
                    //Show account creation alert if the user is not found
                    strongSelf.showAccountCreation(view: MyPlacesVC())
                }
                
            } else {
                print("You have signed in")
                strongSelf.signedIn = true
            }
            
        }
        
    }
    
    func createAccount() {
        //Create the account
        Auth.auth().createUser(withEmail: self.email, password: self.password) { [weak self] authResut, error in
            //Make sure there are no errors
            guard let strongSelf = self else {return}
            
            if error != nil {
                let authError = error as! AuthErrorCode
                
                print("Account creation failed. The Error: \(authError)")
                strongSelf.showMessagePrompt(title: "Error", message: authError.localizedDescription, action: "Try Again", view: MyPlacesVC())
                return
            }
            
            //Get a unique user id
            guard let uid = authResut?.user.uid else {return}
            
            let values = ["email": strongSelf.email]
            
            //Create database reference
            Database.database().reference().child("users").child(uid).updateChildValues(values) { error, ref in
                print("Failed to store to database.", error?.localizedDescription as Any)
            }
            
            //Store the user ID
            strongSelf.userID = uid
            
            //Show successful account creation alert
            strongSelf.showMessagePrompt(title: "Success!", message: "You have successfully created a My Drink account!", action: "OK", view: MyPlacesVC())
            
            strongSelf.signedIn = true
        }
    }
    
    
    //Function to create one alert with one action
    func showMessagePrompt(title: String, message: String, action: String, view: UIViewController) {
        
        //Create alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: action, style: .default, handler: nil))
        //present alert
        view.present(alert, animated: true, completion: nil)
    }
    
    func showAccountCreation(view: UIViewController) {
        
        //Create alert
        let alert = UIAlertController(title: "Create Account?", message: "The email/password entered wasn't recognized. Would you like to try again or create an account using the email and password given?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Create Account", style: .default, handler: { _ in
            //Create an account with the email/password
            self.createAccount()
            
        })
        let dismiss = UIAlertAction(title: "Try Again", style: .cancel, handler: nil)
        alert.addAction(action) ; alert.addAction(dismiss)
        view.present(alert, animated: true, completion: nil)
    }
    
    
}
