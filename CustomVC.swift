//
//  CustomVC.swift
//  Popup
//
//  Created by Fredrik Bixo on 2018-01-25.
//

import Cocoa

class CustomVC: NSViewController {

    override func viewDidLoad() {
        if #available(OSX 10.10, *) {
            super.viewDidLoad()
        } else {
            // Fallback on earlier versions
        }
        // Do view setup here.
    }
    
    override func awakeFromNib() {
        print("hi")
    }
    
}
