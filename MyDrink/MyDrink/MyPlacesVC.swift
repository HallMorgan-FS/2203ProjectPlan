//
//  MyPlacesVC.swift
//  MyDrink
//
//  Created by Morgan Hall on 5/12/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MyPlacesVC: UIViewController {
    
    
    
    //properties
    var userID = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        authenticateAndConfigureView()
    }
    
    func authenticateAndConfigureView() {
        
        //Keep user signed in and show this view if they are signed in
        if Auth.auth().currentUser == nil {
            //Show sign in page
            DispatchQueue.main.async {
                let navController = UINavigationController(rootViewController: ViewController())
                navController.navigationBar.barStyle = .black
                self.present(navController, animated: true, completion: nil)
            }
        } else {
            //Load the saved data
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
