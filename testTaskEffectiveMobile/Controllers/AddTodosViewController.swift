//
//  AddTodosViewController.swift
//  testTaskEffectiveMobile
//
//  Created by Роман Кокорев on 27.08.2024.
//

import UIKit

class AddTodosViewController: UIViewController {
    
    let coreDataManager = CoreDataManager.shared
    
    var lastId: Int32?
    var complited: Bool?
    var newId = Int32()
    var creationDate: Date?
    
    private lazy var todoTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .systemGray6
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 10
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var userIdTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .systemGray6
        textField.placeholder = "Enter user ID"
        textField.leftView = UIView(frame: CGRect(x: 0, y: 10, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 10
        textField.keyboardType = .numberPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var complitedSwitch: UISwitch = {
        let mySwitch = UISwitch()
        mySwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        mySwitch.translatesAutoresizingMaskIntoConstraints = false
        return mySwitch
    }()
    
    private lazy var idLabel: UILabel = {
        let label = UILabel()
        if lastId != nil {
            label.text = "ID: " + String(lastId ?? 0)
        } else {
            label.text = "ID: "
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var todoLabel: UILabel = {
        let label = UILabel()
        label.text = "Todo:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var complitedLabel: UILabel = {
        let label = UILabel()
        label.text = "Complited:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var userIdLabel: UILabel = {
        let label = UILabel()
        label.text = "User ID: "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var creationDataLabel: UILabel = {
        let label = UILabel()
        label.text = "Creation date: "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupConstraint()
        
        creationDate = returnCurrentDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let formattedDate = dateFormatter.string(from: creationDate ?? Date.distantPast)
        creationDataLabel.text = "Creation date: " + formattedDate
    }
    
    func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(idLabel)
        view.addSubview(todoLabel)
        view.addSubview(todoTextView)
        view.addSubview(complitedLabel)
        view.addSubview(complitedSwitch)
        view.addSubview(userIdLabel)
        view.addSubview(userIdTextField)
        view.addSubview(creationDataLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapKeyboardOff(_:)))
        view.addGestureRecognizer(tap)
    }
    
    private func setupNavigationBar() {
        self.navigationItem.title = "New todos"
        navigationItem.backButtonTitle = "Back"
        
        let addNewActionButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.down"), style: .plain,  target: self, action: #selector(saveActionClicked))
        navigationItem.rightBarButtonItems = [addNewActionButton]
    }
    
    func setupConstraint() {
        NSLayoutConstraint.activate([
            idLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            idLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            todoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            todoLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 20),
            
            todoTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            todoTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            todoTextView.topAnchor.constraint(equalTo: todoLabel.bottomAnchor, constant: 10),
            todoTextView.heightAnchor.constraint(equalToConstant: 100),
            
            complitedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            complitedLabel.topAnchor.constraint(equalTo: todoTextView.bottomAnchor, constant: 20),
            
            complitedSwitch.leadingAnchor.constraint(equalTo: complitedLabel.trailingAnchor),
            complitedSwitch.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            complitedSwitch.topAnchor.constraint(equalTo: complitedLabel.topAnchor),
            
            userIdLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            userIdLabel.topAnchor.constraint(equalTo: complitedSwitch.bottomAnchor, constant: 20),
            
            userIdTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            userIdTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            userIdTextField.topAnchor.constraint(equalTo: userIdLabel.bottomAnchor, constant: 10),
            userIdTextField.heightAnchor.constraint(equalToConstant: 50),
            
            creationDataLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            creationDataLabel.topAnchor.constraint(equalTo: userIdTextField.bottomAnchor, constant: 20)
        ])
    }
    
    func returnCurrentDate() -> Date {
        let currentDate = Date()
        return currentDate
    }
    
    @objc func tapKeyboardOff(_ sender: Any) {
        todoTextView.resignFirstResponder()
        userIdTextField.resignFirstResponder()
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        if sender.isOn {
            complited = true
        } else {
            complited = false
        }
    }
    
    @objc func saveActionClicked() {
        let todoText = todoTextView.text ?? ""
        let userIdText = userIdTextField.text ?? ""
        let complitedTodo = complited ?? false
        
        if let lastId {
            newId = lastId + 1
        } else {
            print("Error")
        }
        
        if todoText.isEmpty && userIdText.isEmpty {
            todoTextView.shake()
            userIdTextField.shake()
        } else if todoText.isEmpty  {
            todoTextView.shake()
        } else if userIdText.isEmpty  {
            userIdTextField.shake()
        } else {
            if newId > 1 {
                let todos = Todos(id: newId, todo: todoText, completed: complitedTodo, userId: Int32(userIdText) ?? 0)
                
                coreDataManager.saveTodo(todo: todos) {
                    let alert = UIAlertController(title: "Todos saved", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }                
            }
        }
    }    
}
