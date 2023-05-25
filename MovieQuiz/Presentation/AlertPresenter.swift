//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by macbook on 21.04.2023.
//

import UIKit
class AlertPresenter: AlertPresenterProtocol {
    weak var viewController: MovieQuizViewController?
    init (viewController: MovieQuizViewController){
        self.viewController = viewController
    }
    func show(alert alertModel: AlertModel) {
        /// создаём объекты всплывающего окна
        let alertController = UIAlertController(title: alertModel.title, /// заголовок всплывающего окна
                                                message: alertModel.message, /// текст во всплывающем окне
                                                preferredStyle: .alert) /// preferredStyle может быть .alert или .actionSheet
        
        /// создаём для него кнопки с действиями
        let action = UIAlertAction(title: alertModel.buttonText,
                                   style: .default) { _ in
            alertModel.completion()
        }
        
        /// добавляем в алерт кнопки
        alertController.addAction(action)
        
        /// показываем всплывающее окно
        viewController?.present(alertController, animated: true, completion: nil)
    }
}
