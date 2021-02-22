//
//  Config.swift
//  LousyJob
//
//  Created by Jacob Williams on 2/21/21.
//

import Foundation

struct ConfigJob: Decodable {
    let arguments: [String]?
    let executable: String
    let schedule: String?
    let title: String
}

struct ConfigRoot: Decodable {
    let jobs: [ConfigJob]
}

func loadUserLousyJobConfig() -> ConfigRoot {
    try! JSONDecoder().decode(ConfigRoot.self, from: String(contentsOfFile: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".lousyjob").path).data(using: .utf8)!)
}
