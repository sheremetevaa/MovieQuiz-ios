import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet weak private var tItleQuestionLabel: UILabel!
    @IBOutlet weak private var indexQuestionLabel: UILabel!
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        yesButton.isEnabled = false
        noButton.isEnabled = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        yesButton.isEnabled = false
        noButton.isEnabled = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService = StatisticServiceImplementation()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        
        ///
        
        ///
        super.viewDidLoad()
        tItleQuestionLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        indexQuestionLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        
        alertPresenter = AlertPresenter (viewController: self)
        
    }
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    //  struct ViewModel {
    //        let image: UIImage
    //      let question: String
    //       let questionNumber: String
    //  }
    
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    
    
    private func show(quiz step: QuizStepViewModel) {
        textLabel.text = step.question
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        if isCorrect == true {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
        } else { imageView.layer.borderColor =
            UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            /// запускаем задачу через 1 секунду
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        
        if currentQuestionIndex == questionsAmount - 1 { // -
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let total = statisticService.gamesCount
            let record = String(statisticService.bestGame.correct) + "/" + String(statisticService.bestGame.total)
            let accuracy = statisticService.totalAccuracy
            let date = statisticService.bestGame.date
            
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: "Ваш результат: \(correctAnswers)/\(questionsAmount) \nКоличество сыгранных квизов: \(total)\nРекорд: \(record) (\(date.dateTimeString)) \nСредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%",
                buttonText: "Сыграть еще раз",
                completion: {
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
                })
            //show(quiz: resultViewModel)
            yesButton.isEnabled = true
            noButton.isEnabled = true
            alertPresenter?.show(alert: alertModel)
        } else {
            currentQuestionIndex += 1
            /// увеличиваем индекс текущего урока на 1; таким образом мы сможем получить следующий урок
            questionFactory?.requestNextQuestion()
            yesButton.isEnabled = true
            noButton.isEnabled = true
        }
    }
    
    // private func show(quiz result: QuizResultsViewModel) {
    
    //}
}
/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
