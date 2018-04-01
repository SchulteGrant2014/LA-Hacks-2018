//
//  GroceryItem.swift
//  LA Hacks 2018
//
//  Created by Jeannie Huang on 3/31/18.
//  Copyright © 2018 Consonants. All rights reserved.
//

import Foundation

class GroceryItem{
    let name: String
    let keyID: String
    let price: double_t
    var nutritionJSON : [String : Any]
    let foodGroup: String
    
    init(itemName:String, itemPrice: double_t) {
        name = itemName
        price = itemPrice
        keyID = "-1"
        nutritionJSON = [:]
        foodGroup = ""
    }
    
    init(itemName:String, itemPrice: double_t, ID : String, itemNutrition: [String: Any], fg: String){
        name = itemName
        price = itemPrice
        keyID = "-1"
        nutritionJSON = itemNutrition
        foodGroup = fg
    }
    
    func getKey(){
    // want to search up grocery item key using the search API
    
        // let query = "apples"
        let query = name
        let max_results = "1"
        let api_key =  "1b5LF51ZHbTrasDtok7xgpMFvYTQ2Th698xzyC7J" // key that Cris signed up for
        var search_URL = "https://api.nal.usda.gov/ndb/search/?format=json&q=" + query
        search_URL += "butter&sort=n&max=" + max_results + "&offset=0&api_key=" + api_key
        
        //use search function in API call
        var JSONresponse : [String:Any]
        //** TO DO: search function here
        
        // extract nbdno value from JSON, which is the key
        
        //null value for now
        JSONresponse = [:]
        //** TO DO: check if JSON returned is empty
        //** access NBDHO for key and group for food group
        
        
    }
    
    func getFoodReport() {
    // want to return the JSON for nutrition value for this item. set nutritionJSON = to what this returned
        
        
        
    }
    
    
}
