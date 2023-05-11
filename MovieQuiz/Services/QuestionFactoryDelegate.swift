//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by macbook on 21.04.2023.
//

import Foundation
protocol QuestionFactoryDelegate: AnyObject {               // 1
    func didReceiveNextQuestion(question: QuizQuestion?)    // 2
}
