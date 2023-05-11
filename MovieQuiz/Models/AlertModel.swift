//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by macbook on 02.05.2023.
//

import UIKit
struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: () -> Void
}
