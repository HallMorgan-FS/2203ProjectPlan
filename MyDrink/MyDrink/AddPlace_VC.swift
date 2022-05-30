//
//  AddPlace_VC.swift
//  MyDrink
//
//  Created by Morgan Hall on 5/25/22.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class AddPlace_VC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var cityLabel: UITextField!
    @IBOutlet weak var stateLabel: UITextField!
    @IBOutlet weak var picker: UIPickerView!
    
    //properties
    var selectedState = String()
    var states = ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]
    
    var userID = Auth.auth().currentUser?.uid
    var name = ""
    var city = ""
    var state = ""
    //bool to represent if a place is a favorite place
    var favorite = false
    //create an empty places
    var places = [Place]()
    var favoritePlaces = [Place]()
    var placeValue = [String: Any]()
    
    var database = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        nameLabel.delegate = self
        cityLabel.delegate = self
        stateLabel.delegate = self
        
    }
    
    @IBAction func uniqueLocationButton(_ sender: UIButton) {
    }
    
    @IBAction func addPlaceTapped(_ sender: UIButton) {
        //verify the text entries
        if nameLabel.text == nil || cityLabel.text == nil || stateLabel.text == nil {
            let alert = UIAlertController(title: "Error", message: "All fields must be entered to add a place.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else /* If no fields are left blank save the values */{
            guard let vName = nameLabel.text,let vCity = cityLabel.text, let vState = stateLabel.text else
            {
                print("Failed to unwrap values of place") ; return
            }
            //store values
            name = vName; city = vCity; state = vState
            //store to database
            storeData()
        }
        
        
    }
    
    //function to store to database
    func storeData(){
        
        //create a new place
        let newPlace = Place(name: name, city: city, state: state, drinks: nil)
        
        //add this new place to the places array
        places.append(newPlace)
        
        //create a place value
        placeValue = ["name": name, "city": city, "state": state, "favorite": favorite]
        
        //add the places array to the firebase database by the name of the place as the key
        database.child("Places").child("\(String(describing: userID))").setValue(["place": placeValue]) { error, ref in
            guard error == nil else {print("Failed to store to database.", error?.localizedDescription as Any); return}
            
            //check to see if item is a favorite
            if self.favorite {
                self.favoritePlaces.append(newPlace)
            }
            
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    
    
    @IBAction func favoriteTapped(_ sender: UIBarButtonItem) {
        //Change bar button  image
        let rightBarButton = navigationItem.rightBarButtonItem
        if rightBarButton?.image == UIImage(systemName: "heart.fill"){
            rightBarButton?.image = UIImage(systemName: "heart")
            favorite = false
        } else if rightBarButton?.image == UIImage(systemName: "heart"){
            rightBarButton?.image = UIImage(systemName: "heart.fill")
            favorite = true
        }
        
    }
    
    func verifyEntry() {
        if let vName = nameLabel.text, let vCity = cityLabel.text, let vState = stateLabel.text {
            name = vName; city = vCity; state = vState
        } else if nameLabel.text == nil || cityLabel.text == nil || stateLabel.text == nil {
            let alert = UIAlertController(title: "Error", message: "All fields must be entered to add a place.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            textField.inputView = UIView()
            picker.isHidden = false
        }
    }
    
    // MARK: - Picker View Delegates
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return states.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return states[row] // dropdown item
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedState = states[row]
        
        stateLabel.text = selectedState
        stateLabel.endEditing(true)
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? MyPlacesVC {
            destination.places = self.places
        }
    }
    

}
