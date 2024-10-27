import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    private var alertPresenter: AlertPresenter?
    private var presenter: MovieQuizPresenter!
    
    func configugeTextLabel() {
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = 0.5 // Минимальный масштаб 50% от оригинального размера шрифта
        textLabel.numberOfLines = 2 // Убедитесь, что текст не переносится на следующую строку
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configugeTextLabel()
        presenter = MovieQuizPresenter(viewController: self)
        showLoadingIndicator()
        imageView.layer.cornerRadius = 20
        alertPresenter = AlertPresenter(viewController: self)
    }

    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }

    func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }

    func showLoadingIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }

    func showNetworkError(message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.hideLoadingIndicator()
            let model = AlertModel(title: "Ошибка зарузки данных",
                                   message: "Отсутствует интернет соединение",
                                   buttonText: "Попробовать ещё раз") { [weak self] in
                guard let self = self else { return }
                
                self.presenter.currentQuestionIndex = 0
                self.presenter.correctAnswers = 0
                self.presenter.questionFactory.loadData()
            }
            self.alertPresenter?.showAlert(model: model)
        }
    }

    func show(_ step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderColor = UIColor.clear.cgColor
    }

    func showResult(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText) { [weak self] in
                self?.presenter?.resetQuiz()
            }
        alertPresenter?.showAlert(model: alertModel)
    }

    func setButtonsEnabled(_ isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }

    @IBAction private func noButtonTapped(_ sender: Any) {
        presenter.didAnswer(isYes: false)
    }

    @IBAction private func yesButtonTapped(_ sender: Any) {
        presenter.didAnswer(isYes: true)
    }
}
