import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    @IBOutlet private weak var filmPosterView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet weak var yesButton: UIButton!
    @IBAction private func noButtonClicked(_ sender: Any) {
        showAnswerResult(isCorrect(givenAnswer: false))
        enableButtons(false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        showAnswerResult(isCorrect(givenAnswer: true))
        enableButtons(false)
    }
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenter?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService?
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    enum FileManagerError: Error {
        case fileDoesntExist
    }
    
    func string(from documentsURL: URL) throws -> String {
        if (!FileManager.default.fileExists(atPath: documentsURL.path)) {
            throw FileManagerError.fileDoesntExist
        }
        return try String(contentsOf: documentsURL)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        questionFactory = QuestionFactory(delegate: self)
        alertPresenter = AlertPresenter(delegate: self)
        statisticService = StatisticServiceImplementation()
        questionFactory?.requestNewQuestion()
        
        print(print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!))
    }
    
    // MARK: - Actions
    private func restartQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNewQuestion()
    }
    
    private func continueQuiz() {
        clearBorders(of: filmPosterView)
        if currentQuestionIndex == questionsAmount - 1 {
            showQuizResult()
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNewQuestion()
        }
    }
    
    // MARK: - Show
    private func showQuestion(_ viewModel: QuizStepViewModel) {
            filmPosterView.image = viewModel.image
            textLabel.text = viewModel.questionText
            counterLabel.text = viewModel.questionNumberText
            enableButtons(true)
    }
    
    private func showAnswerResult(_ isCorrect: Bool?) {
        guard let isCorrect = isCorrect else {
            return
        }
        
        if isCorrect {
            correctAnswers += 1
            drawBorders(of: filmPosterView, colored: UIColor.customGreen)
        }
        else {
            drawBorders(of: filmPosterView, colored: UIColor.customRed)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in// запускаем задачу через 1 секунду
            // код, который вы хотите вызвать через 1 секунду,
            guard let self = self else { return }
            self.continueQuiz()
        }
    }
    
    private func showQuizResult() {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        let message = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количество сыгранных квизов: \(statisticService?.gamesCount ?? 1)
        Рекорд: \(statisticService?.bestGame.correct ?? correctAnswers)/\(statisticService?.bestGame.total ?? questionsAmount) (\(statisticService?.bestGame.date.dateTimeString ?? Date().dateTimeString))
        Средняя точность: \(statisticService?.totalAccuracy ?? 0)%
        """
        let viewModel = QuizResultsViewModel(title: "Этот раунд окончен!", text: message, buttonText: "Сыграть ещё раз")
        alertPresenter?.showAlert(viewModel)
    }

    // MARK: - Tools
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.imageName) ?? UIImage(),
            questionText: model.questionText,
            questionNumberText:"\(currentQuestionIndex+1) / \(questionsAmount)"
        )
    }
    
    private func isCorrect(givenAnswer: Bool) -> Bool? {
        guard let currentQuestion = currentQuestion else {
            return nil
        }
        return currentQuestion.correctAnswer == givenAnswer
    }

    // MARK: - Draw & Clear
    private func drawBorders(of image: UIImageView, colored color: UIColor){
        image.layer.masksToBounds = true
        image.layer.borderWidth = 8
        image.layer.borderColor = color.cgColor
    }
    
    private func clearBorders(of image: UIImageView) {
        image.layer.borderWidth = 0
    }
    
    private func enableButtons(_ isEnable: Bool) {
        noButton.isEnabled = isEnable
        yesButton.isEnabled = isEnable
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.showQuestion(viewModel)
        }
        showQuestion(viewModel)
    }
    
    // MARK: - AlertPresenterDelegate
    
    func onCloseAlert() {
        print("Step 3: On Close Alert")
        restartQuiz()
    }
}























