import UIKit

// MARK: - ViewModels
private struct QuizStepViewModel {
    let image: UIImage
    let questionText: String
    let questionNumberText: String
}

private struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}

private struct AnswerResultViewModel {
    let correctAnswer: Bool
}

private struct QuizQuestion {
    let imageName: String
    let questionText: String
    let correctAnswer: Bool
}

final class MovieQuizViewController: UIViewController {
    
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
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private var playedQuizCounter: Int = 0
    private var bestResult: Int = 0
    private var bestResultDate: Date = Date()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showQuestion(indexOf: currentQuestionIndex)
    }
    
    // MARK: - Mock-данные
    private let questions: [QuizQuestion] = [
        QuizQuestion(imageName: "The Godfather", questionText: "Рейтинг этого фильма больше чем 6?" , correctAnswer: true),
        QuizQuestion(imageName: "The Dark Knight", questionText: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(imageName: "Kill Bill", questionText: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(imageName: "The Avengers", questionText: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(imageName: "Deadpool", questionText: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(imageName: "The Green Knight", questionText: "Рейтинг этого фильма больше чем 6?" , correctAnswer: true),
        QuizQuestion(imageName: "Old", questionText: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(imageName: "The Ice Age Adventures of Buck Wild", questionText: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(imageName: "Tesla", questionText: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(imageName: "Vivarium", questionText: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
    ]
    
    // MARK: - Show
    private func restartQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        showQuestion(indexOf: 0)
    }
    
    private func continueQuiz() {
        clearBorders(of: filmPosterView)
        if currentQuestionIndex == questions.count - 1 {
            endQuiz()
        } else {
            currentQuestionIndex += 1
            showQuestion(indexOf: currentQuestionIndex)
        }
    }
    
    private func endQuiz() {
        playedQuizCounter += 1
        saveBestResultIfNeeded()
        let resultAccuracy = (Float(correctAnswers) * 100 / Float(questions.count)).rounded(.toNearestOrEven)
        let formattedDate = bestResultDate.formatted(date: .numeric, time: .standard)
        let text = """
        Ваш результат: \(correctAnswers) из \(questions.count)
        Количество сыгранных квизов: \(playedQuizCounter)
        Средняя точность: \(resultAccuracy)%
        """
        //Рекорд: \(bestResult)/\(questions.count) (\(formattedDate))"
        let viewModel = QuizResultsViewModel(title: "Этот раунд окончен!", text: text, buttonText: "Сыграть ещё раз")
        showQuizResult(viewModel)
    }
    
    private func saveBestResultIfNeeded() {
        if (correctAnswers > bestResult) {
            bestResult = correctAnswers
            bestResultDate = Date()
        }
    }
    
    private func showQuestion(indexOf index: Int ) {
        let viewModel = convert(model: questions[index])
        filmPosterView.image = viewModel.image
        textLabel.text = viewModel.questionText
        counterLabel.text = viewModel.questionNumberText
        enableButtons(true)
    }
    
    private func showQuizResult(_ viewModel: QuizResultsViewModel) {
        // создаём объекты всплывающего окна
        let alert = UIAlertController(title: viewModel.title, // заголовок всплывающего окна
                                      message: viewModel.text, // текст во всплывающем окне
                                      preferredStyle: .alert) // preferredStyle может быть .alert или .actionSheet

        // создаём для него кнопки с действиями
        let action = UIAlertAction(title: "Сыграть ещё раз", style: .default, handler: { _ in
            print("OK button is clicked!")
            self.restartQuiz()
        })

        // добавляем в алерт кнопки
        alert.addAction(action)

        // показываем всплывающее окно
        present(alert, animated: true, completion: nil)
    }
    
    private func showAnswerResult(_ isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
            drawBorders(of: filmPosterView, colored: UIColor.customGreen)
        }
        else {
            drawBorders(of: filmPosterView, colored: UIColor.customRed)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // запускаем задачу через 1 секунду
            // код, который вы хотите вызвать через 1 секунду,
            self.continueQuiz()
        }
    }
    
    // MARK: - Convert
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(named: model.imageName) ?? UIImage(),
            questionText: model.questionText,
            questionNumberText:"\(currentQuestionIndex+1) / \(questions.count)"
        )
    }
    
    private func isCorrect(givenAnswer: Bool) -> Bool {
        return questions[currentQuestionIndex].correctAnswer == givenAnswer
    }

    
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
}
