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
    
    // -------------------- Member Functions --------------------
    
    init(image: UIImage) {
        itemList = MakeItemList(image: image)
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
    
    return apiResponseJSON
    
}


//extract individual items given an imageJson
func MakeItemList(image: UIImage) -> [GroceryItem] {
    
    var googleVisionJSON: [String:Any] = MakeGoogleVisionAPIRestCall(image: image)  // Call the Google Vision API to return a json
    
    let response = googleVisionJSON["responses"] as! [[String:Any]]
    let textAnnotations = response[0]["textAnnotations"] as! [[String:Any]]
    let fullText: String = textAnnotations[0]["description"] as! String  // Get ALL text from receipt, rows separated by new line characters
    print(fullText)
    var rowsText: [String] = extractRows(fullTextWithNewlines: fullText)  // Get a list of the individual rows from the receipt
    
    print(rowsText)
    // Convert row text to grocery items
    
    
    return []  // Return list of grocery items inferred from all rows of receipt
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
