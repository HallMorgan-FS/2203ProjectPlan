//
//  UserDefaults_ext.swift
//  MyDrink
//
//  Created by Morgan Hall on 5/29/22.
//

import Foundation

extension UserDefaults {
    
    //save places array
    func setPlaces(array: [Place], forKey key: String) {
        
        //Save the data to UserDefaults
        self.set(array, forKey: key)
    }
    
   
    
    
    
    
    
    
    
}
