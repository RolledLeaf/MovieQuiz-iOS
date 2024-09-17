import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var alertPresenter: AlertPresenter?
    private var presenter: MovieQuizPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        showLoadingIndicator()
        imageView.layer.cornerRadius = 20
        alertPresenter = AlertPresenter(viewController: self)
    }
    
    internal func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = true
        }
    }
    
    internal func showLoadingIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }
    
     func showNetworkError(message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            hideLoadingIndicator() // скрываем индикатор загрузки
            let model = AlertModel(title: "Ошибка зарузки данных",
                                   message: "Отсутствует интернет соединение",
                                   buttonText: "Попробовать ещё раз") { [weak self] in
                guard let self = self else { return }
                
                presenter.currentQuestionIndex = 0
                presenter.correctAnswers = 0
                presenter.questionFactory.loadData()
            }
            self.alertPresenter?.showAlert(model: model)
        }
    }
    
     func show(_ step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        // Сбрасываем цвет рамки при показе нового вопроса
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    @IBAction private func noButtonTapped(_ sender: Any) {
        presenter.didAnswer(isYes: false)
    }
    
    @IBAction private func yesButtonTapped(_ sender: Any) {
        presenter.didAnswer(isYes: true)
    }
}
