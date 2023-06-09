//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by macbook on 01.06.2023.
//

import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    //func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    
    func showAlert(_ model: AlertModel)
    func enableButtons()
    func disableButtons()
}

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactoryProtocol?
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private let statisticService: StatisticService!
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    init (viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate

    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator() // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    func didFailToLoadImage(with error: Error) {
        let model = AlertModel(
            title: "Ошибка",
            message: error.localizedDescription,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                guard let self = self else { return }
                // Нужно перезагрузить картинку
            })
        viewController?.showAlert(model)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }

    
var correctAnswers: Int = 0
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
            if isCorrectAnswer {
                correctAnswers += 1
            }
        }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
        private func didAnswer(isYes: Bool){
        guard let currentQuestion = currentQuestion else {
            return
        }

        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        //self.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        viewController?.disableButtons()
        }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)

            viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.proceedToNextQuestionOrResults()
            }
        }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: self.questionsAmount)

            let bestGame = statisticService.bestGame
            let gamesCount = statisticService.gamesCount
            let date = bestGame.date.dateTimeString
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: "Ваш результат: \(correctAnswers)/\(self.questionsAmount) \nКоличество сыгранных квизов: \(gamesCount)\nРекорд: \(bestGame.correct)/\(self.questionsAmount)  (\(date)) \nСредняя точность:\(String(format: "%.2f", statisticService.totalAccuracy))%",

                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    self?.restartGame()
                    self?.correctAnswers = 0
                    self?.questionFactory?.requestNextQuestion()
                })
            //show(quiz: resultViewModel)
            viewController?.enableButtons()
            viewController?.showAlert(alertModel)
        } else {
            self.switchToNextQuestion()
            /// увеличиваем индекс текущего урока на 1; таким образом мы сможем получить следующий урок
            questionFactory?.requestNextQuestion()
            viewController?.enableButtons()
        }
    }
    
    func showAnswerResult(isCorrect: Bool) {
        didAnswer(isYes: isCorrect)
                
                viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let self = self else { return }
                    self.proceedToNextQuestionOrResults()
                }
    }
}
