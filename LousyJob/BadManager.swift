import Cocoa

class BadManager {
    var configJob: ConfigJob
    var process: Process?
    var menuItem: NSMenuItem
    var menuItemRun: NSMenuItem
    var menuItemKill: NSMenuItem
    var menuItemCopyPid: NSMenuItem
    
    init(configJob: ConfigJob) {
        self.configJob = configJob
        menuItem = NSMenuItem()
        let submenu = NSMenu()
        submenu.autoenablesItems = false
        menuItem.submenu = submenu
        menuItemRun = NSMenuItem()
        menuItemRun.title = "Run"
        menuItemRun.action = #selector(self.run)
        submenu.addItem(menuItemRun)
        menuItemKill = NSMenuItem()
        menuItemKill.title = "Kill"
        menuItemKill.action = #selector(self.kill)
        submenu.addItem(menuItemKill)
        menuItemCopyPid = NSMenuItem()
        menuItemCopyPid.title = "Kill"
        menuItemCopyPid.action = #selector(self.copyPid)
        submenu.addItem(menuItemCopyPid)
        menuItemRun.target = self
        menuItemKill.target = self
        menuItemCopyPid.target = self
    }
    
    @objc func recheck() {
        if process != nil {
            if !process!.isRunning {
                process = nil
            }
        }
        menuItemRun.isEnabled = (process == nil)
        menuItemKill.isEnabled = (process != nil)
        if let pr = process {
            menuItemCopyPid.isEnabled = true
            menuItemCopyPid.title = "Copy pid \(pr.processIdentifier)"
        } else {
            menuItemCopyPid.isEnabled = false
            menuItemCopyPid.title = "Copy pid"
        }
    }
    
    func reload() {
        recheck()
        menuItem.title = configJob.title
    }
    
    @objc func run() {
        if process != nil {
            return
        }
        process = Process()
        process!.launchPath = configJob.executable
        process!.arguments = configJob.arguments
        process!.terminationHandler = { p in self.recheck() }
        process!.launch()
        recheck()
    }
    
    @objc func kill() {
        process?.terminate()
    }
    
    @objc func copyPid() {
        if let pr = process {
            let pb = NSPasteboard.general
            pb.declareTypes([.string], owner: nil)
            pb.setString("\(pr.processIdentifier)", forType: .string)
        }
    }
}
