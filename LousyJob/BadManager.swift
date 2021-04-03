import Cocoa
import SwiftUI

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
    var menuItemViewLousyjobLog: NSMenuItem
    var lastinc: Incident?
    
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
        menuItemViewLousyjobLog = NSMenuItem()
        menuItemViewLousyjobLog.title = "View lousyjob log"
        menuItemViewLousyjobLog.action = #selector(self.viewLousyjobLog)
        submenu.addItem(menuItemViewLousyjobLog)
        menuItemRun.target = self
        menuItemKill.target = self
        menuItemCopyPid.target = self
        menuItemViewStdout.target = self
        menuItemViewStderr.target = self
        menuItemViewLousyjobLog.target = self
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
        checkDue()
    }
    
    func checkDue() {
        if process != nil {
            return
        }

        if let interval = configJob.interval {
            if let inc = lastinc {
                let due = inc.date + TimeInterval(interval)
                if due <= Date() {
                    run()
                }
            } else {
                run()
            }
        }
    }
    
    func refresh() {
        recheck()
        menuItem.image = NSImage(systemSymbolName: "questionmark.circle", accessibilityDescription: "unclear")
        if process != nil {
            menuItem.image = NSImage(systemSymbolName: "ellipsis.rectangle", accessibilityDescription: "running")
        } else if let inc = lastinc {
            if inc.kind == .finished {
                if inc.exitCode == 0 {
                    menuItem.image = NSImage(systemSymbolName: "checkmark", accessibilityDescription: "succeeded")
                } else {
                    menuItem.image = NSImage(systemSymbolName: "xmark.circle", accessibilityDescription: "failed")
                }
            }
        }
    }
    
    func reload() {
        loadLastIncident()
        refresh()
        menuItem.title = configJob.title
    }
    
    @objc func run() {
        if process != nil {
            return
        }
        process = Process()
        process!.launchPath = configJob.executable
        process!.arguments = configJob.arguments
        process!.terminationHandler = { p in self.refresh() }
        let foutpath = stdoutLogPath()
        if !FileManager.default.fileExists(atPath: foutpath) {
            FileManager.default.createFile(atPath: foutpath, contents: nil, attributes: nil)
        }
        fout = FileHandle(forWritingAtPath: foutpath)
        try! fout!.seekToEnd()
        process!.standardOutput = fout!
        let ferrpath = stderrLogPath()
        if !FileManager.default.fileExists(atPath: ferrpath) {
            FileManager.default.createFile(atPath: ferrpath, contents: nil, attributes: nil)
        }
        ferr = FileHandle(forWritingAtPath: ferrpath)
        try! ferr!.seekToEnd()
        process!.standardError = ferr!
        process!.launch()
        
        let inc = Incident(kind: .started, date: .init(), jobId: configJob.id, pid: process!.processIdentifier, exitCode: nil, executable: process!.launchPath, arguments: process!.arguments)
        record(incident: inc)
        
        refresh()
    }
    
    func loadLastIncident() {
        lastinc = nil
        let flogpath = lousyjobLogPath()
        if FileManager.default.fileExists(atPath: flogpath) {
            // TODO this is wasteful, we only need to read near the end of the file
            let flogstr = try! String(contentsOfFile: flogpath)
            if let line = flogstr.trimmingCharacters(in: .newlines).split(separator: "\n").last {
                lastinc = Incident.from(json: String(line))
            }
        }
    }
    
    func record(incident: Incident) {
        lastinc = incident
        let fpath = lousyjobLogPath()
        if !FileManager.default.fileExists(atPath: fpath) {
            FileManager.default.createFile(atPath: fpath, contents: nil, attributes: nil)
        }
        if let flj = FileHandle(forWritingAtPath: fpath) {
            try! flj.seekToEnd()
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
    
    @objc func viewLousyjobLog() {
        viewInConsole(path: lousyjobLogPath())
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
