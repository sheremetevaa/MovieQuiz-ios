//
//  GameRecordModel.swift
//  MovieQuiz
//
//  Created by macbook on 04.05.2023.
//

import Foundation
struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
}
