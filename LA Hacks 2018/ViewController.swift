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
    
    @IBAction func printAPIResponse(_ sender: UIButton) {
        print(apiResponseJSON)
    }
    
    
    // -------------------- Default functions --------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Initialize a new receipt
        let url_string: String = "https://api.nal.usda.gov/ndb/search/?format=json&q=butter&sort=n&max=25&offset=0&api_key=DEMO_KEY"
        self.apiResponseJSON = RESTCall(url: url_string, jsonRequestAsDictionary: nil).doRESTCall(requestType: "POST")
        print(self.apiResponseJSON)
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
    
}


