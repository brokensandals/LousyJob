import Cocoa

class BadManager {
    var configJob: ConfigJob
    var process: Process?
    var menuItem: NSMenuItem
    var menuItemRun: NSMenuItem
    var timer: Timer?
    
    init(configJob: ConfigJob) {
        self.configJob = configJob
        menuItem = NSMenuItem()
        let submenu = NSMenu()
        submenu.autoenablesItems = false
        menuItem.submenu = submenu
        menuItemRun = NSMenuItem()
        menuItemRun.title = "Run now"
        menuItemRun.target = self
        menuItemRun.action = #selector(self.run)
        submenu.addItem(menuItemRun)
    }
    
    @objc func recheck() {
        if process != nil {
            if !process!.isRunning {
                process = nil
                timer?.invalidate()
            }
        }
        menuItemRun.isEnabled = (process == nil)
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
        process!.launch()
        timer = Timer(timeInterval: 3.0, target: self, selector: #selector(self.recheck), userInfo: nil, repeats: true)
        timer!.tolerance = 1.0
        RunLoop.current.add(timer!, forMode: .common)
        recheck()
    }
}
