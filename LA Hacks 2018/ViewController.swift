//
//  ViewController.swift
//  LA Hacks 2018
//
//  Created by Grant Schulte on 3/31/18.
//  Copyright © 2018 Consonants. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    // -------------------- Member Variables ---------------------
    
    var apiResponseJSON : [String : Any] = [:]
    
    
    
    // -------------------- Default functions --------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        MakeGoogleVisionAPIRestCall(image: UIImage(imageLiteralResourceName: "CalPolyAcceptance"))
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // -------------------- UI Element Function Connections --------------------
    
    @IBAction func openImageViewController(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    // ------------------------- GOOGLE VISION API REST CALL -------------------------
    
    func MakeGoogleVisionAPIRestCall(image: UIImage) {
        let googleVisionAPI_url : String = "https://vision.googleapis.com/v1/images:annotate"
        let apiKey_url : String = "AIzaSyBGDpjGUxH2Qz5STe50j4QZl-mTeco0ms8"
        let url_string : String = googleVisionAPI_url + "?key=" + apiKey_url
        
        guard let url = URL(string: url_string) else {
            print("Error: cannot create URL")
            return
        }
        
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
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        let jsonData: Data
        do {
            jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            urlRequest.httpBody = jsonData  // Set the JSON data to be the body of the request... Will send JSON to Google Vision API
            print("JSON sterilization of request dictionary was successful")
        } catch {
            print("Error: cannot create JSON from data")
            return
        }
        
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else {
                print("error calling POST on /todos/1")
                print(error!)
                return
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            // parse the result as JSON, since that's what the API provides
            do {
                guard let receivedData = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    print("Could not get JSON from responseData as dictionary")
                    return
                }
                print("Data received...")
                self.apiResponseJSON = receivedData
                print(receivedData)
            } catch  {
                print("error parsing response from POST on /todos")
                return
            }
        }
        task.resume()
    }
    
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


