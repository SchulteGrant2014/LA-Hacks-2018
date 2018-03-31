//
//  GroceryItem.swift
//  LA Hacks 2018
//
//  Created by Jeannie Huang on 3/31/18.
//  Copyright © 2018 Consonants. All rights reserved.
//

import Foundation

class Item{
    let name: String
    let keyID: String
    let price: double_t
    var nutritionJSON : [String : Any]
    
    init(itemName:String) {
        name = itemName
        price = -1
        keyID = "-1"
        nutritionJSON = [:]
    }
    
    init(itemName:String, itemPrice: double_t, ID : String, itemNutrition: [String: Any]){
        name = itemName
        price = itemPrice
        keyID = "-1"
        nutritionJSON = itemNutrition
    }
    
    func getKey(){
    // want to search up grocery item key using the search API
    
    }
    
    func getFoodReport() {
    // want to return the JSON for nutrition value for this item. set nutritionJSON = to what this returned
    }
    
    
}
