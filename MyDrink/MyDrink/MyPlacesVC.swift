//
//  MyPlacesVC.swift
//  MyDrink
//
//  Created by Morgan Hall on 5/12/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MyPlacesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
   
    //Outlets for ViewController
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    
    
    //create an empty places list
    var places = [Place]()
    var filteredPlaces = [[Place]()]
    var userID = String()
    var database = Database.database().reference()
    var favoritePlaces = [Place]()
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        authenticateAndConfigureView()
        navigationController?.navigationBar.isHidden = false
        
        if let uid = defaults.object(forKey: "uid") as? String {
            userID = uid
        }
        
        //Set selection during editing
        /* Can't set editing until I get the palces to show up*/
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //readFirebaseData()
        
        if places.count != 0 {
            tableView.delegate = self
            tableView.isHidden = false
            directionLabel.isHidden = true
            searchBar.isHidden = false
            editButton.isHidden = false
            tableView.reloadData()
        }
        
    }
    
    func authenticateAndConfigureView() {
        
        //Keep user signed in and show this view if they are signed in
        if Auth.auth().currentUser == nil {
            //Make MyPlacesVC the root navigation controller
            let navController = UINavigationController(rootViewController: SignInViewController())
            navController.isNavigationBarHidden = true
            navController.isToolbarHidden = true
            
        } else {
            //Load the saved data
            tableView.delegate = self
            if places.count != 0 {
                tableView.isHidden = false
                directionLabel.isHidden = true
                searchBar.isHidden = false
                editButton.isHidden = false
                tableView.reloadData()
            }
            
        }
        
    }
    
    //load the saved data
    func readFirebaseData() {
        //Read data and put it into the correct values
        database.child("Places/\(String(describing: userID))").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  let placeName = value["name"] as? String,
                  let placeCity = value["city"] as? String,
                  let placeState = value["state"] as? String,
                  let favPlace = value["favorite"] as? Bool
            else {
                return
            }
            //Create new place from the loaded data
            let newPlace = Place(name: placeName, city: placeCity, state: placeState, drinks: nil)
            
            self.places.append(newPlace)
            if favPlace {
                self.favoritePlaces.append(newPlace)
            }
            
            self.directionLabel.isHidden = true
            self.tableView.isHidden = false
            self.searchBar.isHidden = false
            self.editButton.isHidden = false
            self.tableView.delegate = self
            self.tableView.reloadData()
        }
        
        
    }
    
    //MARK: ACTIONS AND FUNCTIONS FOR VC
    
    @IBAction func addPlaceTapped(_ sender: UIBarButtonItem) {
        navigationController?.show(AddPlace_VC(), sender: self)
    }
    
    @IBAction func editTapped(_ sender: UIButton) {
    }
    
    @IBAction func logOutTapped(_ sender: UIBarButtonItem) {
        //Ask the user if they want to log out with an alert
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Log Out", style: .default, handler: { _ in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                self.navigationController?.popToRootViewController(animated: true)
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        //present alert
        present(alert, animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reuse_ID", for: indexPath) as? MyPlacesCell
        else {
            return tableView.dequeueReusableCell(withIdentifier: "reuse_ID", for: indexPath)
        }
        
        //configure the cell
        let currentPlace = places[indexPath.row]
        cell.placeLabel.text = currentPlace.name
        cell.numDrinksLabel.text = "\(currentPlace.drinks.count)"
       
        
        return cell
    }
    
    //Header methods
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//
//        return places[section].address
//    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func filterPlaces() {
        //filter the places by their state
        
        
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? AddPlace_VC {
            //set the database and the userID
            destination.database = self.database
            
        }
    }
    

}
