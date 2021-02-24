import Cocoa

class BadManager {
    var configJob: ConfigJob
    var process: Process?
    var menuItem: NSMenuItem
    var menuItemRun: NSMenuItem
    
    init(configJob: ConfigJob) {
        self.configJob = configJob
        menuItem = NSMenuItem()
        let submenu = NSMenu()
        menuItem.submenu = submenu
        menuItemRun = NSMenuItem()
        menuItemRun.title = "Run now"
        menuItemRun.target = self
        menuItemRun.action = #selector(self.run)
        submenu.addItem(menuItemRun)
    }
    
    func reload() {
        menuItem.title = configJob.title
        menuItemRun.isEnabled = (process == nil)
    }
    
    @objc
    func run() {
        if process != nil {
            return
        }
        process = Process()
        process!.launchPath = configJob.executable
        process!.arguments = configJob.arguments
        process!.launch()
    }
}
