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
    var config: ConfigRoot?
    var jobManagers: [BadManager] = []
    @IBOutlet weak var statusBarMenu: NSMenu?


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength);
        if let button = self.statusBarItem.button {
            button.title = "¯\\_(ツ)_/¯"
        }
        
        if let statusBarMenu = statusBarMenu {
            statusBarItem.menu = statusBarMenu
        }
        
        reload()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    @objc
    func reload() {
        jobManagers = []
        config = loadUserLousyJobConfig();
        let menu = statusBarItem.menu!
        menu.items.removeAll()
        for job in config!.jobs {
            let manager = BadManager(configJob: job)
            jobManagers.append(manager)
            let jobitem = NSMenuItem()
            jobitem.title = job.title
            let jobmenu = NSMenu()
            jobitem.submenu = jobmenu
            let runitem = NSMenuItem()
            runitem.title = "Run now"
            runitem.target = manager
            runitem.action = #selector(manager.run)
            jobmenu.addItem(runitem)
            menu.addItem(jobitem)
        }
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Reload", action: #selector(self.reload), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApp.terminate(_:)), keyEquivalent: ""))
    }
}

