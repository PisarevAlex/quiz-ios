import UIKit

class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate) {
        self.delegate = delegate
    }
    
    func showAlert(_ viewModel: QuizResultsViewModel?) {
        print("Step 1: Show Alert")
        guard let viewModel = viewModel else {
            return
        }
        
        let alert = UIAlertController(title: viewModel.title, // заголовок всплывающего окна
                                      message: viewModel.text, // текст во всплывающем окне
                                      preferredStyle: .alert) // preferredStyle может быть .alert или .actionSheet

        // создаём для него кнопки с действиями
        let action = UIAlertAction(title: "Сыграть ещё раз", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            print("Step 2: Close Alert")
            self.delegate?.onCloseAlert()
        })

        // добавляем в алерт кнопки
        alert.addAction(action)

        // показываем всплывающее окно
        delegate?.present(alert, animated: true, completion: nil)
    }
}
