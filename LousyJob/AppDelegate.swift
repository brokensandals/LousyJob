import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var statusBarItem: NSStatusItem!
    var config: ConfigRoot?
    var jobManagers: [String: BadManager] = [:]
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

    @objc func reload() {
        config = loadUserLousyJobConfig();
        let menu = statusBarItem.menu!
        menu.items.removeAll()
        for job in config!.jobs {
            let manager = jobManagers[job.id] ?? BadManager(configJob: job)
            jobManagers[job.id] = manager
            manager.reload()
            menu.addItem(manager.menuItem)
        }
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Reload", action: #selector(self.reload), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApp.terminate(_:)), keyEquivalent: ""))
    }
}

