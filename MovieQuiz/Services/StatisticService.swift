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
    func store(correct count: Int, total amount: Int){
        gamesCount = gamesCount + 1
        correctCount = correctCount + count
        totalAmount = totalAmount + amount
        totalAccuracy = Double(correctCount) / Double(totalAmount) * 100
        
        if bestGame.total == 0 ||  Double(bestGame.correct)/Double(bestGame.total) < Double(count)/Double(amount){
            bestGame = .init(correct: count, total: amount, date: Date())
        }
    }
    var totalAccuracy: Double {
        get {
            return userDefaults.double(forKey: Keys.totalAccuracy.rawValue)
        }
        set
        {
            userDefaults.set(newValue, forKey: Keys.totalAccuracy.rawValue)
        }
    }
    
    var correctCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    var totalAmount: Int {
        get {
            return userDefaults.integer(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
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
    
    
}
