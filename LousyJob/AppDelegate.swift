//
//  AppDelegate.swift
//  LousyJob
//
//  Created by Jacob Williams on 2/6/21.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var statusBarItem: NSStatusItem!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let contentView = ContentView()
        
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength);
        if let button = self.statusBarItem.button {
            button.title = "¯\\_(ツ)_/¯"
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }


}

