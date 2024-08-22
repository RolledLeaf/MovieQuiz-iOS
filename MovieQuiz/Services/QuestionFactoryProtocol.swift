import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion() 
    func setup(delegate: QuestionFactoryDelegate) 
}
