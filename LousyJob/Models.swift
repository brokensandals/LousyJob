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

enum IncidentKind: String, Codable {
    case started, finished
}

struct Incident: Codable {
    let kind: IncidentKind
    let date: Date
    let jobId: String
    let pid: Int32?
    let exitCode: Int32?
    let executable: String?
    let arguments: [String]?
    
    func toJSON() -> Data {
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601
        return try! enc.encode(self)
    }
}
