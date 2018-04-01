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
    
    var receipts: [Receipt] = []
    var idealRelativeNutrientPerc: [String:Double] = [ "Protein":11.34594, "Fats":13.570634, "Carbohydrates":61.179088, "Sugars":6.896552, "Dietary Fiber":7.007786 ]
    // Nutrients = ["Protein","Fats","Carbohydrates","Sugars","Dietary Fiber"]
    
    // -------------------- Default functions --------------------
    
    func userData() {
        // call class method
        var userDefaults = UserDefaults.standard
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.        
        var testReceipt: Receipt
        if let img = UIImage(named: "tj1") {
            testReceipt = Receipt(image: img)
        } else {
            //print("I didn't run :(")
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // -------------------- UI Element Function Connections --------------------
    
    @IBAction func unwindToViewController(_ sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? AddImageViewController {
            if let image = sourceViewController.ImageDisplay.image {
                if receipts.count == 5 {
                    receipts.removeFirst(1)
                    receipts.append(Receipt(image: image))
                } else {receipts.append(Receipt(image: image))}
            }
        }
    }
    
    
}


