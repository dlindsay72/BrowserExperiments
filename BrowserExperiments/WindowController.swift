//
//  WindowController.swift
//  BrowserExperiments
//
//  Created by Dan Lindsay on 2017-02-10.
//  Copyright © 2017 Dan Lindsay. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    @IBOutlet var addressEntry: NSTextField!
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        window?.titleVisibility = .hidden
        
    }

}
