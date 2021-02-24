import Foundation

struct ConfigJob: Decodable {
    let arguments: [String]?
    let executable: String
    let id: String
    let schedule: String?
    let title: String
}

struct ConfigRoot: Decodable {
    let jobs: [ConfigJob]
    let logdir: String
}

func loadUserLousyJobConfig() -> ConfigRoot {
    try! JSONDecoder().decode(ConfigRoot.self, from: String(contentsOfFile: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".lousyjob").path).data(using: .utf8)!)
}
