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
    var nutritionDict: [String : Double]
    
    init(itemName: String) {
        name = itemName
        keyID = getKey(nameOfItem: itemName)
        if let key = keyID {
            self.nutritionDict = GetNutrientInfo(usdaFoodID: key)
        } else {
            self.nutritionDict = [:]
        }
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
    
}



func GetNutrientInfo(usdaFoodID: String) -> [String : Double] {
    
    // Set up the request to the USDA nutrition API
    let api_key =  "1b5LF51ZHbTrasDtok7xgpMFvYTQ2Th698xzyC7J" // key that Cris signed up for
    var url_string: String = "https://api.nal.usda.gov/ndb/V2/reports?ndbno=" + usdaFoodID + "&type=f&format=json&api_key=" + api_key
    
    // Make the REST call to get a response containing nutrition info for the food
    var responseJSON: [String:Any] = RESTCall(url: url_string, jsonRequestAsDictionary: nil).doRESTCall()
    
    // Parse the response JSON for the nutrients we want:
    // { Protein [ID 203]; Total lipid (fat) [ID 204]; Carbohydrate, by difference [ID 205]; Sugars, total [ID 269]; Fiber, total dietary [ID 291] }
    var nutrDict: [String:Double] = [:]  // Dictionary holding nutrient types and the number of grams of that nutrient per 100g of food
    let nutrIdList = [ 203, 204, 205, 269, 291 ]
    let nutrTranslateDict: [Int:String] = [ 203:"Protein", 204:"Fats", 205:"Carbohydrates", 269:"Sugars", 291:"Dietary Fiber"]
    
    for nutr in nutrIdList {
        nutrDict[nutrTranslateDict[nutr]!] = 0.0
    }
    
    if let _ = responseJSON["foods"] {
        
        let foods = responseJSON["foods"] as! [[String:Any]]
        let food = foods[0]["food"] as! [String:Any]
        let nutrients = food["nutrients"] as! [[String:Any]]  // List of dicts
        
        print(nutrients)
        
        // Search all nutrient types for ones we care about
        
        for nutr in nutrients {
            for id in nutrIdList {
                var idInJSON = nutr["nutrient_id"]
                //let specificNutrientID: String = idInJSON as! NSString
                let specificNutrientID: String = "\(idInJSON!)"
                print("------------ FOOD ID = " + usdaFoodID + " ------------ " + specificNutrientID + " ------------")
                if (Int(specificNutrientID) == id) {
                    let nutrientName: String = nutrTranslateDict[id]!
                    let nutrientValue: String = "\(nutr["value"]!)"
                    nutrDict[nutrientName] = Double(nutrientValue)
                    //print("i ran" + String(nutrDict.count))
                    break  // Found the nutrient, stop searching
                } else {
                    //print("i didn't run :(")
                }
            }
        }
        
    }
    
    print("$$$$$$$$$ - " + String(nutrDict.count) + "$$$$$$$$$$$$$")
    return nutrDict
    
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

