//
//  RESTCall.swift
//  LA Hacks 2018
//
//  Created by Grant Schulte on 3/31/18.
//  Copyright © 2018 Consonants. All rights reserved.
//

import UIKit


class RESTCall {
    
    let url_string: String
    let jsonRequestDict: [String : Any]?
    
    init(url: String, jsonRequestAsDictionary: [String : Any]?) {
        self.url_string = url
        self.jsonRequestDict = jsonRequestAsDictionary
    }
    
    
    
    // -------------------- MAKE THE REST CALL, RETURN JSON DICTIONARY --------------------
    
    func doRESTCall(requestType: String = "POST") -> [String:Any] {
        var response: [String:Any]? = nil
        while (response == nil) {
            if let responseJSON = RESTCall(url: url_string, jsonRequestAsDictionary: nil).REST_backend() {
                response = responseJSON
            }
        }
        return response!
    }
    
    
    
    func REST_backend(requestType: String = "POST") -> [String : Any]? {
        guard let url = URL(string: url_string) else {
            print("Error: cannot create URL")
            return nil
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = requestType  // "POST" by default
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        if let requestJSON = jsonRequestDict {
            let jsonData: Data
            do {
                jsonData = try JSONSerialization.data(withJSONObject: requestJSON, options: [])
                urlRequest.httpBody = jsonData  // Set the JSON data to be the body of the request... Will send JSON to Google Vision API
                print("JSON sterilization of request dictionary was successful")
            } catch {
                print("Error: cannot create JSON from data")
                return nil
            }
        }
        
        let session = URLSession.shared
        var apiResponseJSON: [String:Any] = [:]
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
            
            // Parse the result as JSON, since that's what the API provides
            do {
                guard let receivedData = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    print("Could not get JSON from responseData as dictionary")
                    return
                }
                print("Data received...")
                apiResponseJSON = receivedData
                //print(receivedData)
            } catch  {
                print("error parsing response from POST on /todos")
                return
            }
        }
        task.resume()
        
        return apiResponseJSON  // Return the JSON response that was sent from the API
    }
    
}



