//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by macbook on 01.06.2023.
//

import UIKit

final class MovieQuizPresenter {
    //    private
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticService = StatisticServiceImplementation()
    
    //statisticService = StatisticServiceImplementation()

    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
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
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        viewController?.yesButton.isEnabled = false
        viewController?.noButton.isEnabled = false
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked(_ sender: UIButton) {
        didAnswer(isYes: false)
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
    
func showNextQuestionOrResults() {
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
                    self?.resetQuestionIndex()
                    self?.correctAnswers = 0
                    self?.questionFactory?.requestNextQuestion()
                })
            //show(quiz: resultViewModel)
            viewController?.yesButton.isEnabled = true
            viewController?.noButton.isEnabled = true
            viewController?.alertPresenter?.show(alert: alertModel)
        } else {
            self.switchToNextQuestion()
            /// увеличиваем индекс текущего урока на 1; таким образом мы сможем получить следующий урок
            questionFactory?.requestNextQuestion()
            viewController?.yesButton.isEnabled = true
            viewController?.noButton.isEnabled = true
        }
    }
    
}
