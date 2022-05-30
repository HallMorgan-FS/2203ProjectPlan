//
//  MyPlacesCell.swift
//  MyDrink
//
//  Created by Morgan Hall on 5/16/22.
//

import UIKit

class MyPlacesCell: UITableViewCell {
    
    @IBOutlet weak var placeLabel: UILabel!
    
    @IBOutlet weak var numDrinksLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
