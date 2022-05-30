//
//  Drink.swift
//  MyDrink
//
//  Created by Morgan Hall on 5/16/22.
//

import Foundation

class Drink {
    
    var name: String
    var alcohol: String
    var type: String
    var notes: String
    
    init(name: String, alcohol: String, type: String, notes: String) {
        self.name = name
        self.alcohol = alcohol
        self.type = type
        self.notes = notes
    }
    
    convenience init(name: String, alcohol: String, type:String, notes: String?) {
        if notes == nil {
            self.init(name: name, alcohol: alcohol, type: type, notes: String())
        } else {
            self.init(name: name, alcohol: alcohol, type: type, notes: notes)
        }
    }
    
}
