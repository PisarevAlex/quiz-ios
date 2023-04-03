import Foundation

class QuestionFactory : QuestionFactoryProtocol {
    
    weak var delegate: QuestionFactoryDelegate?
    
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
    
    init(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    func requestNewQuestion() {
        guard let index = (0..<questions.count).randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }
        
        let question = questions[safe: index]
        delegate?.didReceiveNextQuestion(question: question)
    }
}
