import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var statusBarItem: NSStatusItem!
    var config: ConfigRoot?
    var jobManagers: [String: BadManager] = [:]
    @IBOutlet weak var statusBarMenu: NSMenu?
    var timer: Timer?


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
        if let tim = timer {
            tim.invalidate()
            timer = nil
        }

        config = loadUserLousyJobConfig();
        let menu = statusBarItem.menu!
        menu.items.removeAll()
        for job in config!.jobs {
            let manager = jobManagers[job.id] ?? BadManager(config: config!, configJob: job)
            jobManagers[job.id] = manager
            manager.configJob = job
            manager.reload()
            menu.addItem(manager.menuItem)
        }
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Reload", action: #selector(self.reload), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApp.terminate(_:)), keyEquivalent: ""))

        timer = Timer(timeInterval: TimeInterval(config!.interval), target: self, selector: #selector(self.refresh), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    @objc func refresh() {
        for manager in jobManagers.values {
            manager.refresh()
        }
    }
}

