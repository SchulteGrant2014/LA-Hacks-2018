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
    
    
    
    // -------------------- Default functions --------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var testReceipt: Receipt
        if let img = UIImage(named: "tj3") {
            testReceipt = Receipt(image: img)
        }
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


