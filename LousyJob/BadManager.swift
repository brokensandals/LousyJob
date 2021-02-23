//
//  BadManager.swift
//  LousyJob
//
//  Created by Jacob Williams on 2/21/21.
//

import Foundation

class BadManager {
    var configJob: ConfigJob
    var process: Process?
    
    init(configJob: ConfigJob) {
        self.configJob = configJob
    }
    
    @objc
    func run() {
        process = Process()
        process!.launchPath = configJob.executable
        process!.arguments = configJob.arguments
        process!.launch()
    }
}
