//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by macbook on 21.04.2023.
//

import Foundation
protocol QuestionFactoryDelegate: AnyObject {              
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
    func didFailToLoadImage(with error: Error) // сообщение об ошибке загрузки картинки
}
