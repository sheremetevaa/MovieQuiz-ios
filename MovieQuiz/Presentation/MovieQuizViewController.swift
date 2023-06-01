import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet weak private var tItleQuestionLabel: UILabel!
    @IBOutlet weak private var indexQuestionLabel: UILabel!
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!    
//var questionFactory: QuestionFactoryProtocol?
var alertPresenter: AlertPresenterProtocol?
    //var currentQuestion: QuizQuestion?

    private let presenter = MovieQuizPresenter()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        presenter.viewController = self
        
        tItleQuestionLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        indexQuestionLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20)
        
        imageView.layer.cornerRadius = 20
        
        presenter.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        showLoadingIndicator()
        presenter.questionFactory?.loadData()
        alertPresenter = AlertPresenter (viewController: self)
        presenter.questionFactory?.requestNextQuestion()
        
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked(noButton)
    }
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        presenter.questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true // индикатор скрыт
    }
    
   func didReceiveNextQuestion(question: QuizQuestion?) {
       presenter.didReceiveNextQuestion(question: question)
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
        alertPresenter?.show(alert: model)
    }
    
func show(quiz step: QuizStepViewModel) {
        textLabel.text = step.question
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        
    }
    
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        if isCorrect == true {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            presenter.correctAnswers += 1
        } else { imageView.layer.borderColor =
            UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            /// запускаем задачу через 1 секунду
            self.presenter.correctAnswers = self.presenter.correctAnswers
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    private func showNetworkError(message: String) {
        
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать ещё раз",
                               completion: { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
            self.presenter.questionFactory?.requestNextQuestion()
        })
        
        alertPresenter?.show(alert: model)
    }
    
    private func showNextQuestionOrResults(isCorrect: Bool) {
        if presenter.isLastQuestion(){
            presenter.showNextQuestionOrResults()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let self = self else { return }
            self.presenter.correctAnswers = self.presenter.correctAnswers
            self.presenter.questionFactory = self.presenter.questionFactory
            self.presenter.showNextQuestionOrResults()
        }
}
}
