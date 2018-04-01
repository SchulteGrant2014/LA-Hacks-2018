//
//  AddImageViewController.swift
//  LA Hacks 2018
//
//  Created by Shirlyn Tang on 3/31/18.
//  Copyright © 2018 Consonants. All rights reserved.
//

import UIKit

class AddImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // init buttons and imageview
    @IBOutlet weak var Camera: UIButton!
    @IBOutlet weak var PhotoLibrary: UIButton!
    @IBOutlet weak var ImageDisplay: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    // open camera to take image
    @IBAction func CameraAction(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
    }
    
    // open photos to load image
    @IBAction func PhotoLibraryAction(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    // see image in viewer
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        ImageDisplay.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
    
    // Add image to UIImageView when button is pressed, so when segue occurs the receipt is created
    @IBAction func createReceiptButton(_ sender: UIButton) {
        ImageDisplay.image = UIImage(named: "tj3")
    }
    
}

