import Cocoa

class BadManager {
    var config: ConfigRoot
    var configJob: ConfigJob
    var process: Process?
    var menuItem: NSMenuItem
    var menuItemRun: NSMenuItem
    var menuItemKill: NSMenuItem
    var menuItemCopyPid: NSMenuItem
    var menuItemViewStdout: NSMenuItem
    var menuItemViewStderr: NSMenuItem
    
    var fout: FileHandle?
    var ferr: FileHandle?
    
    init(config: ConfigRoot, configJob: ConfigJob) {
        self.config = config
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
        menuItemViewStdout = NSMenuItem()
        menuItemViewStdout.title = "View stdout log"
        menuItemViewStdout.action = #selector(self.viewStdout)
        submenu.addItem(menuItemViewStdout)
        menuItemViewStderr = NSMenuItem()
        menuItemViewStderr.title = "View stderr log"
        menuItemViewStderr.action = #selector(self.viewStderr)
        submenu.addItem(menuItemViewStderr)
        menuItemRun.target = self
        menuItemKill.target = self
        menuItemCopyPid.target = self
        menuItemViewStdout.target = self
        menuItemViewStderr.target = self
    }
    
    @objc func recheck() {
        if let pr = process {
            if !pr.isRunning {
                if pr.terminationStatus != 0 {
                    let notif = NSUserNotification()
                    notif.title = configJob.title
                    notif.subtitle = "Failed with exit code \(pr.terminationStatus)"
                    NSUserNotificationCenter.default.deliver(notif)
                }
                let inc = Incident(kind: .finished, date: .init(), jobId: configJob.id, pid: pr.processIdentifier, exitCode: pr.terminationStatus, executable: pr.launchPath, arguments: pr.arguments)
                record(incident: inc)
                process = nil
                try? fout?.close()
                fout = nil
                try? ferr?.close()
                ferr = nil
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
        let foutpath = stdoutLogPath()
        if !FileManager.default.fileExists(atPath: foutpath) {
            FileManager.default.createFile(atPath: foutpath, contents: nil, attributes: nil)
        }
        fout = FileHandle(forWritingAtPath: foutpath)
        if #available(OSX 10.15.4, *) {
            try! fout!.seekToEnd()
        }
        process!.standardOutput = fout!
        let ferrpath = stderrLogPath()
        if !FileManager.default.fileExists(atPath: ferrpath) {
            FileManager.default.createFile(atPath: ferrpath, contents: nil, attributes: nil)
        }
        ferr = FileHandle(forWritingAtPath: ferrpath)
        if #available(OSX 10.15.4, *) {
            try! ferr!.seekToEnd()
        }
        process!.standardError = ferr!
        process!.launch()
        
        let inc = Incident(kind: .started, date: .init(), jobId: configJob.id, pid: process!.processIdentifier, exitCode: nil, executable: process!.launchPath, arguments: process!.arguments)
        record(incident: inc)
        
        recheck()
    }
    
    func record(incident: Incident) {
        let fpath = lousyjobLogPath()
        if !FileManager.default.fileExists(atPath: fpath) {
            FileManager.default.createFile(atPath: fpath, contents: nil, attributes: nil)
        }
        if let flj = FileHandle(forWritingAtPath: fpath) {
            if #available(OSX 10.15.4, *) {
                try! flj.seekToEnd()
            } else {
                flj.seekToEndOfFile()
            }
            flj.write(incident.toJSON())
            flj.write("\n".data(using: .utf8)!)
            try? flj.close()
        } else {
            // TODO
        }
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
    
    
    @objc func viewStdout() {
        viewInConsole(path: stdoutLogPath())
    }
    
    @objc func viewStderr() {
        viewInConsole(path: stderrLogPath())
    }
    
    private func viewInConsole(path: String) {
        NSWorkspace.shared.openFile(path, withApplication: "Console")
    }
    
    private func stdoutLogPath() -> String {
        return NSString(string: "\(config.logdir)/\(configJob.id).out").expandingTildeInPath
    }
    
    private func stderrLogPath() -> String {
        return NSString(string: "\(config.logdir)/\(configJob.id).err").expandingTildeInPath
    }
    
    private func lousyjobLogPath() -> String {
        return NSString(string: "\(config.logdir)/\(configJob.id).lousyjob.jsonl").expandingTildeInPath
    }
}
