import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(otherResult: Int) -> Bool {
        return self.correct > otherResult
    }
}

protocol StatisticService {
    func store(correct count: Int, total amount: Int )
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}

final class StatisticServiceImplementation : StatisticService {
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    func store(correct count: Int, total amount: Int) {

        gamesCount += 1
        
        if (!bestGame.isBetterThan(otherResult: count)) {
            bestGame = GameRecord(correct: count, total: amount, date: Date())
        }
    }
    
    var totalAccuracy: Double {
        get {
            let correctAnswers = bestGame.correct
            let totalAnswers = bestGame.total
            let resultAccuracy = (Double(correctAnswers) * 100 / Double(totalAnswers)).rounded(.toNearestOrEven)
            return resultAccuracy
        }
    }
    
    var gamesCount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue) else {
                userDefaults.set(1, forKey: Keys.gamesCount.rawValue)
                return .init(1)
            }
            let optionalString = String(data: data, encoding: .utf8)
            return Int(optionalString!)!
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    
}
