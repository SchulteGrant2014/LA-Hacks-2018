//
//  AddImageViewController.swift
//  LA Hacks 2018
//
//  Created by Shirlyn Tang on 3/31/18.
//  Copyright © 2018 Consonants. All rights reserved.
//

import UIKit

class AddImageViewController: UIViewController {
    
    @IBOutlet weak var Camera: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    @IBAction func CameraAction(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
    }
    
    
}

