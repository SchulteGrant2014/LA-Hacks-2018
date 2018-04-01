//
//  aboutController.swift
//  LA Hacks 2018
//
//  Created by Cristopher Garduno on 4/1/18.
//  Copyright © 2018 Consonants. All rights reserved.
//

import UIKit

class aboutController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }
    
    @IBAction func unwindToViewController(_ sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ViewController {
            
        }
    }
    
    
    
    /*
     @IBAction func unwindToViewController(_ sender: UIStoryboardSegue) {
         if let sourceViewController = sender.source as? AddImageViewController {
             if let image = sourceViewController.ImageDisplay.image {
     
     
     
     
     
     
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
