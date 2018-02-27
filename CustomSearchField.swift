//
//  CustomSearchField.swift
//  Popup
//
//  Created by Fredrik Bixo on 2018-01-30.
//

import Cocoa

class CustomSearchField: NSTextFieldCell {

   
    
    override func drawingRect(forBounds theRect: NSRect) -> NSRect {
        let newRect = NSRect(x: 0, y: (theRect.size.height - 40) / 2, width: theRect.size.width, height: 40)
        return super.drawingRect(forBounds: newRect)
    }
    
}
