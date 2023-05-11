//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by macbook on 04.05.2023.
//

import Foundation
protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get set }
    var gamesCount: Int { get set }
    var bestGame: GameRecord { get set }
}
final class StatisticServiceImplementation {
    private let userDefaults = UserDefaults.standard
    private enum Keys: String {
        case correct, total, bestGame, gamesCount, totalAccuracy
    }
}
extension StatisticServiceImplementation: StatisticService {
    var gamesCount: Int {
            get {
                return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
            }
            set {
                userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
                
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
    
    var totalAccuracy: Double {
        get {
            return userDefaults.double(forKey: Keys.totalAccuracy.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.totalAccuracy.rawValue) }
    }
    
    var correctCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
            
        }
    }
    
    func store(correct count: Int, total amount: Int){
        if bestGame.correct/bestGame.total < count/amount {
          bestGame = GameRecord(correct: count, total: amount, date: Date())
        }
    }
   
    
}
