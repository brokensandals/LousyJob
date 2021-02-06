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
    @IBOutlet weak var statusBarMenu: NSMenu?


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength);
        if let button = self.statusBarItem.button {
            button.title = "¯\\_(ツ)_/¯"
        }
        
        if let statusBarMenu = statusBarMenu {
            statusBarItem.menu = statusBarMenu
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }


}

