//
//  BadManager.swift
//  LousyJob
//
//  Created by Jacob Williams on 2/21/21.
//

import Foundation

class BadManager {
    var configJob: ConfigJob
    
    init(configJob: ConfigJob) {
        self.configJob = configJob
    }
    
    @objc
    func run() {
        let process = Process()
        process.launchPath = configJob.executable
        process.arguments = configJob.arguments
        process.launch()
    }
}
