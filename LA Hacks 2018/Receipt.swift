//
//  Receipt.swift
//  LA Hacks 2018
//
//  Created by Grant Schulte on 3/31/18.
//  Copyright © 2018 Consonants. All rights reserved.
//

import UIKit

class Receipt {
    
    // -------------------- Member Variables --------------------
    
    var itemList: [GroceryItem]
    var nutrientWeightsOfTotal: [String:Double]  // Store percent by weight of nutrient out of total weight of food
    var nutritionFactsTotal: [String:Double]  // Store percentages of each macronutrient by weight relative to each other
    // Nutrients = ["Protein","Fats","Carbohydrates","Sugars","Dietary Fiber"]
    
    // -------------------- Member Functions --------------------
    
    init(image: UIImage) {
        self.itemList = MakeItemList(image: image)
        self.nutrientWeightsOfTotal = PercentOfNutrientsPerTotalWeightOfFood(foods: itemList)
        self.nutritionFactsTotal = RelativeGroceryNutrients(nutrientWeights: self.nutrientWeightsOfTotal)
    }
}


// ------------------------- GOOGLE VISION API REST CALL -------------------------

func MakeGoogleVisionAPIRestCall(image: UIImage) -> [String : Any] {
    let googleVisionAPI_url : String = "https://vision.googleapis.com/v1/images:annotate"
    let apiKey_url : String = "AIzaSyBGDpjGUxH2Qz5STe50j4QZl-mTeco0ms8"
    let url_string : String = googleVisionAPI_url + "?key=" + apiKey_url
    
    // Convert image to base64 format
    let image_as_base64: String = base64EncodeImage(image)
    // JSON request data
    let data = [
        "requests": [
            "image": [
                "content": image_as_base64
            ],
            "features": [
                [
                    "type": "DOCUMENT_TEXT_DETECTION"//,
                    //"maxResults": 10
                ]
            ]
        ]
    ]
    
    // Perform a REST_API call to the Google Vision API
    let apiResponseJSON = RESTCall(url: url_string, jsonRequestAsDictionary: data).doRESTCall()
    print("Done with Vision API REST call")
    
    return apiResponseJSON
    
}


//extract individual items given an imageJson
func MakeItemList(image: UIImage) -> [GroceryItem] {
    
    var googleVisionJSON: [String:Any] = MakeGoogleVisionAPIRestCall(image: image)  // Call the Google Vision API to return a json
    
    var rowsText: [String] = []
    if let response = googleVisionJSON["responses"] as? [[String : Any]] {
        if let textAnnotations = response[0]["textAnnotations"] as? [[String:Any]] {
            if let fullText: String = textAnnotations[0]["description"] as? String {  // Get ALL text from receipt, rows separated by new line characters
                print(fullText)
                rowsText = extractRows(fullTextWithNewlines: fullText)  // Get a list of the individual rows from the receipt
            }
        }
    }
    
    
    print(rowsText)
    
    // Convert row text to grocery items
    var listOfGroceries: [GroceryItem] = []
    var reading: Bool = false
    for row in rowsText {
        
        // Make the row mutable
        var currentRead = row
        
        // Start reading after "OPEN 8:00AM TO 9:00PM DAILY"
        if (currentRead.starts(with: "OPEN")) {
            reading = true
            continue
        }
        // If haven't reached "OPEN 8:00AM TO 9:00PM DAILY" yet, not food so don't consider!
        if (reading == false) {
            continue
        }
        
        // Check for invalid reads, such as if the read is a price or a label like "TOTAL"
        if let numberNotWord = Double(currentRead.split(separator: " ")[0]) {
            continue  // If a number/price, don't search
        } else if currentRead.starts(with: "$") {
            continue  // If a price, don't search
        } else if currentRead == "SUBTOTAL" || currentRead == "TOTAL" {
            break  // If we hit the total/subtotal, we are done reading valid items... break!
        }
        
        // Run through read and chech if there is an invalid character/word/number in it. If so, remove it.
        // Remove anything that isn't a letter"
        currentRead = currentRead.components(separatedBy: CharacterSet(charactersIn: "0123456789")).joined(separator: "")
        var invalidSeqs = ["%", "#", "&", "OZ", ".", "Count", "COUNT", "Pack", "PACK", "EACH", "@", "LB", "CT", "DZ", "LRG", "ORGANIC", "ORG", "LARGE", "SMALL", "TJ'S", "TJS", "TJ", "R-", "A-", "W/", "/", "EA  EA"]
        for invalid in invalidSeqs {
            if currentRead.contains(invalid) {
                currentRead = currentRead.replacingOccurrences(of: invalid, with: "")
            }
        }
        
        // Now that the invalid cases have been handled, the remaining string is a valid read, unless it is empty. Add to the grocery list.
        let item: GroceryItem = GroceryItem(itemName: currentRead)
        if (item.isValid()) {
            listOfGroceries.append(item)
        } else {
            print("------------------------------------\nEliminating " + item.name + "\n---------------------------------------")
            continue
        }
        
    }
    
    print("List of groceries")
    print("List of groceries")
    print("List of groceries")
    print("List of groceries")
    print("List of groceries")
    print("List of groceries")
    for x in listOfGroceries {
        print(x.name + "     " + x.keyID!)
    }
    
    return listOfGroceries  // Return list of grocery items inferred from all rows of receipt
}



func PercentOfNutrientsPerTotalWeightOfFood(foods: [GroceryItem]) -> [String:Double] {
    
    // Go through each nutrient in each item, storing the sum in a dictionary
    
    var aggregateDict : [String:Double] = [:]
    let nutrList = ["Protein","Fats","Carbohydrates","Sugars","Dietary Fiber"]
    for item in foods {
        for nutrient in nutrList {
            let valPer100g = item.nutritionDict[nutrient]!
            print(item.name + "  " + nutrient + " = " + String(valPer100g))
            if let existingValOfNutrient = aggregateDict[nutrient] {
                aggregateDict[nutrient] = existingValOfNutrient + valPer100g
            } else {
                aggregateDict[nutrient] = valPer100g
            }
        }
    }
    
    for nutrient in nutrList {
        let numberOfFoods: Int = foods.count
        if let nutrVal = aggregateDict[nutrient] {
            aggregateDict[nutrient] = nutrVal / Double(numberOfFoods)  // grams of nutrient per 100 grams of food, average over receipt
        }
    }
    
    // Check nutrient values of all foods
    print("\n")
    for nutr in nutrList {
        print(nutr + " = Aggregate " + String(aggregateDict[nutr]!))
    }
    
    // Find the total
    
    return aggregateDict
}



func RelativeGroceryNutrients(nutrientWeights: [String:Double]) -> [String:Double] {
    
    // Get the total weight of all nutrients, then divide each nutrient by the total weight to yield the percentages of each nutrient in relation to the others
    var sumOfWeights: Double = 0.0
    for nutrient in nutrientWeights {
        sumOfWeights += nutrient.value
    }
    
    // Get the relative weight of each
    var relativeNutrientWeights: [String:Double] = [:]
    for nutrient in nutrientWeights {
        relativeNutrientWeights[nutrient.key] = (nutrient.value / sumOfWeights) * Double(100)
    }
    
    // Print the results
    for nutrient in relativeNutrientWeights {
        print(nutrient.key + " = " + String(nutrient.value) + "% of all macronutrients")
    }
    
    // Return the relative weights of all nutrients in a dictionary
    return relativeNutrientWeights
    
}



func extractRows(fullTextWithNewlines: String) -> [String] {
    
    var rows: [String] = []
    fullTextWithNewlines.enumerateLines { (line, _) -> () in
        rows.append(line)
    }
    
    return rows
}



// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}



// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}



func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
    UIGraphicsBeginImageContext(imageSize)
    image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    let resizedImage = UIImagePNGRepresentation(newImage!)
    UIGraphicsEndImageContext()
    return resizedImage!
}



func base64EncodeImage(_ image: UIImage) -> String {
    var imagedata = UIImagePNGRepresentation(image)
    
    // Resize the image if it exceeds the 2MB API limit
    if (imagedata?.count > 2097152) {
        let oldSize: CGSize = image.size
        let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
        imagedata = resizeImage(newSize, image: image)
    }
    
    return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
}

