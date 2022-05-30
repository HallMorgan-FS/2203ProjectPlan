//
//  Place.swift
//  MyDrink
//
//  Created by Morgan Hall on 5/16/22.
//

import Foundation

class Place {
    
    var name: String
    var city: String
    var state: String
    var drinks: [Drink]
    
    var address: String {
        return "\(city), \(state)"
    }
    
    init(name: String, city: String, state: String, drinks: [Drink]) {
        self.name = name.uppercased()
        self.city = city.uppercased()
        self.state = state.uppercased()
        self.drinks = drinks
        
    }
    
    convenience init(name: String, city: String, state: String, drinks: [Drink]?) {
        if drinks != nil {
            self.init(name: name, city: city, state: state, drinks: drinks)
        } else {
            self.init(name: name, city: city, state: state, drinks: [Drink]())
        }
    }
    
}
