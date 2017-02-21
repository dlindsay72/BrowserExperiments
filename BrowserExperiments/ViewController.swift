//
//  ViewController.swift
//  BrowserExperiments
//
//  Created by Dan Lindsay on 2017-02-10.
//  Copyright © 2017 Dan Lindsay. All rights reserved.
//

import Cocoa
import WebKit

extension NSTouchBarItemIdentifier {
    
    static let navigation = NSTouchBarItemIdentifier("com.hackingwithswift.project4.navigation")
    static let enterAddress = NSTouchBarItemIdentifier("com.hackingwithswift.project4.enterAddress")
    static let sharingPicker = NSTouchBarItemIdentifier("com.hackingwithswift.project4.sharingPicker")
    static let adjustGrid = NSTouchBarItemIdentifier("com.hackingwithswift.project4.adjustGrid")
    static let adjustRows = NSTouchBarItemIdentifier("com.hackingwithswift.project4.adjustRows")
    static let adjustCols = NSTouchBarItemIdentifier("com.hackingwithswift.project4.adjustCols")
}

class ViewController: NSViewController, WKNavigationDelegate, NSGestureRecognizerDelegate, NSTouchBarDelegate {
    
    var rows: NSStackView!
    var selectedWebView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        //1 - create the stackView and add it to our view
        rows = NSStackView()
        rows.orientation = .vertical
        rows.distribution = .fillEqually
        rows.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rows)
        
        //2 - create autoLayout constraints that pin the stackview to the edges of its container
        rows.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        rows.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        rows.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        rows.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        //3 - create an initial column that contains a single web view
        let column = NSStackView(views: [makeWebView()])
        column.distribution = .fillEqually
        
        //4 - add this column to the rows stackView
        rows.addArrangedSubview(column)
    }
    
    

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func urlEntered(_ sender: NSTextField) {
        
        //bail out if we don't have a web view selected
        guard let selected = selectedWebView else { return }
        
        //attempt to convert the user's text into a URL
        if let url = URL(string: sender.stringValue) {
            
            // it worked - load it up
            selected.load(URLRequest(url: url))
        }
    }
    
    @IBAction func navigationClicked(_ sender: NSSegmentedControl) {
        
        // make sure we have a web view selected
        guard let selected = selectedWebView else { return }
        
        if sender.selectedSegment == 0 {
            //back was tapped
            selected.goBack()
        } else {
            //forward was tapped
            selected.goForward()
        }
    }
    
    @IBAction func adjustRows(_ sender: NSSegmentedControl) {
        
        if sender.selectedSegment == 0 {
            
            //we're adding a row
            
            //count how many columns we have so far
            let columnCount = (rows.arrangedSubviews[0] as! NSStackView).arrangedSubviews.count
            
            //make a new array of web views that contain the correct number of columns
            let viewArray = (0 ..< columnCount).map { _ in makeWebView() }
            
            //use that web view to create a new stack view
            let row = NSStackView(views: viewArray)
            
            //make the stack view size its children equally, then add it to our rows array
            row.distribution = .fillEqually
            rows.addArrangedSubview(row)
            
        } else {
            
            //we're deleting a row
            
            //make sure we have at least two rows
            guard rows.arrangedSubviews.count > 1  else { return }
            
            //pull out the final row, and make sure its a stack view
            guard let rowToRemove = rows.arrangedSubviews.last as? NSStackView else { return }
            
            //loop through each web view in the row, removing it from the screen
            for cell in rowToRemove.arrangedSubviews {
                
                cell.removeFromSuperview()
            }
            
            //finally, remove the whole stack view row
            rows.removeArrangedSubview(rowToRemove)
        }
        
    }
    
    @IBAction func adjustColumns(_ sender: NSSegmentedControl) {
        
        if sender.selectedSegment == 0 {
            
            //we need to add a column
            for case let row as NSStackView in rows.arrangedSubviews {
                
                //loop over each row and add a new web view to it
                row.addArrangedSubview(makeWebView())
            }
            
        } else {
            
            //we need to delete a column
            
            //pull out the first of our rows
            guard let firstRow = rows.arrangedSubviews.first as? NSStackView else { return }
            
            //make sure it has at least two columns
            guard firstRow.arrangedSubviews.count > 1 else { return }
            
            //if we are still here it means it's safe to delete a column
            for case let row as NSStackView in rows.arrangedSubviews {
                
                //loop over every row
                if let last = row.arrangedSubviews.last {
                    
                    //pull out the last web view in this column and remove it using the two-step process
                    row.removeArrangedSubview(last)
                    last.removeFromSuperview()
                }
            }
        }
    }
    
    func makeWebView() -> NSView {
        
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.wantsLayer = true
        webView.load(URLRequest(url: URL(string: "https://www.apple.com")!))
        
        // 2 ways to disambiguate clicks
        
//        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(webViewClicked))
//        recognizer.numberOfClicksRequired = 2
//        webView.addGestureRecognizer(recognizer)
        
        
        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(webViewClicked))
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
        
        if selectedWebView == nil {
            select(webView: webView)
        }
        
        return webView
    }
    
    func select(webView: WKWebView) {
        
        selectedWebView = webView
        selectedWebView.layer?.borderColor = NSColor.blue.cgColor
        selectedWebView.layer?.borderWidth = 4
        
        if let WindowController = view.window?.windowController as? WindowController {
            WindowController.addressEntry.stringValue = selectedWebView.url?.absoluteString ?? ""
        }
    }
    
    func webViewClicked(recognizer: NSClickGestureRecognizer) {
        //get the web view that triggered this method
        guard let newSelectedWebView = recognizer.view as? WKWebView else { return }
        
        //deselect the currently selected web view if there is one
        if let selected = selectedWebView {
            selected.layer?.borderWidth = 0
        }
        
        //select one
        select(webView: newSelectedWebView)
    }
    
    func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldAttemptToRecognizeWith event: NSEvent) -> Bool {
        if gestureRecognizer.view == selectedWebView {
            return false
        } else {
            return true
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
        guard webView == selectedWebView else { return }
        
        if let windowController = view.window?.windowController as? WindowController {
            windowController.addressEntry.stringValue = webView.url?.absoluteString ?? ""
        }
    }
    
    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
        
        switch identifier {
        case NSTouchBarItemIdentifier.enterAddress:
            let button = NSButton(title: "Enter a URL", target: self, action: #selector(selectedAddressEntry))
            button.setContentHuggingPriority(10, for: .horizontal)
            let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
            
            customTouchBarItem.view = button
            return customTouchBarItem
        default:
            return nil
        }
    }
    
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        
        //enable the Customize Touch Bar menu item
        NSApp.isAutomaticCustomizeTouchBarMenuItemEnabled = true
        
        //create a Touch Bar with a unique identifier, making ViewController its delegate
        let touchBar = NSTouchBar()
        touchBar.customizationIdentifier = NSTouchBarCustomizationIdentifier("com.hackingwithswift.project4")
        touchBar.delegate = self
        
        //set up some meaningful defaults
        touchBar.defaultItemIdentifiers = [.navigation, .adjustGrid, .enterAddress, .sharingPicker]
        
        //make the address entry button sit in the center of the bar
        touchBar.principalItemIdentifier = .enterAddress
        
        //allow the user to customize these four controls
        touchBar.customizationAllowedItemIdentifiers = [.sharingPicker, .adjustGrid, .adjustCols, .adjustRows]
        
        //but don't let them take off the URL entry button
        touchBar.customizationRequiredItemIdentifiers = [.enterAddress]
        
        return touchBar
    }
    
    func selectedAddressEntry() {
        
        if let windowController = view.window?.windowController as? WindowController {
            windowController.window?.makeFirstResponder(windowController.addressEntry)
        }
    }


}










