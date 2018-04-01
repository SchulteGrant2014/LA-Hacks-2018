//
//  GroceryItem.swift
//  LA Hacks 2018
//
//  Created by Jeannie Huang on 3/31/18.
//  Copyright © 2018 Consonants. All rights reserved.
//

import UIKit

class GroceryItem {
    let name: String
    let keyID: String?
    var nutritionJSON : [String : Any]
    let foodGroup: String
    
    init(itemName: String) {
        name = itemName
        keyID = getKey(nameOfItem: itemName)
        nutritionJSON = [:]
        foodGroup = ""
    }
    
    
    // Tests if this is a valid item, i.e. - if its name was found in the NIH database
    func isValid() -> Bool {
        if (keyID == nil) {
            return false
        }
        //var nameCopy: String = self.name
        var newName: String = self.name.replacingOccurrences(of: " ", with: "")
        if (newName == "") {
            return false
        }
        
        return true
    }
    
    
    func getFoodReport() {
        // want to return the JSON for nutrition value for this item. set nutritionJSON = to what this returned
        
        
    }
    
    
}


func getKey(nameOfItem: String) -> String? {
    // want to search up grocery item key using the search API
    
    // let query = "apples"
    let query = nameOfItem.replacingOccurrences(of: " ", with: "+")
    let max_results = "1"
    let api_key =  "1b5LF51ZHbTrasDtok7xgpMFvYTQ2Th698xzyC7J" // key that Cris signed up for
    var search_URL = "https://api.nal.usda.gov/ndb/search/?format=json&q=" + query
    search_URL += "&sort=r&max=" + max_results + "&offset=0&api_key=" + api_key
    
    //use search function in API call
    var JSONresponse : [String:Any]
    JSONresponse = RESTCall(url: search_URL, jsonRequestAsDictionary: nil).doRESTCall()
    print("Done with NIH API REST call")
    print(JSONresponse)
    // extract nbdno value from JSON, which is the key
    var foodID: String? = nil
    if let _ = JSONresponse["list"] {  // Test that there are no errors (success if "list" exists, fail if "errors" exists)
        let list = JSONresponse["list"] as! [String:Any]
        let item = list["item"] as! [[String:Any]]
        foodID = item[0]["ndbno"] as! String
    } else {
        return nil  // FAILED search: no items exist, so return nil to indicate failure
    }
    
    
    return foodID
}

