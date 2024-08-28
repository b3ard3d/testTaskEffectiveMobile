//
//  EditingTodosViewController.swift
//  testTaskEffectiveMobile
//
//  Created by Роман Кокорев on 28.08.2024.
//

import UIKit

class EditingTodosViewController: UIViewController {
    
    let coreDataManager = CoreDataManager.shared
        
    var selectedId, selectedUserId: Int32?
    var selectedTodo: String?
    var selectedCompleted: Bool?
    var selectedCreationDate: Date?
    
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
        //mySwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        mySwitch.translatesAutoresizingMaskIntoConstraints = false
        return mySwitch
    }()
    
    private lazy var idLabel: UILabel = {
        let label = UILabel()
        if selectedId != nil {
            label.text = "ID: " + String(selectedId ?? 0)
        } else {
            label.text = "ID: "
        }
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let formattedDate = dateFormatter.string(from: selectedCreationDate ?? Date.distantPast)
        
        if selectedUserId != nil {
            label.text = "Creation date: " + formattedDate
        } else {
            label.text = "Creation date: "
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupConstraint()
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
        
        todoTextView.text = selectedTodo
        complitedSwitch.setOn(selectedCompleted ?? false, animated: true)
        userIdTextField.text = String(selectedUserId ?? 0)
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
    
    @objc func tapKeyboardOff(_ sender: Any) {
        todoTextView.resignFirstResponder()
        userIdTextField.resignFirstResponder()
    }
    
    @objc func saveActionClicked() {
        let todoText = todoTextView.text ?? ""
        let userIdText = userIdTextField.text ?? ""
        
        if todoText.isEmpty && userIdText.isEmpty {
            todoTextView.shake()
            userIdTextField.shake()
        } else if todoText.isEmpty  {
            todoTextView.shake()
        } else if userIdText.isEmpty  {
            userIdTextField.shake()
        } else {
            coreDataManager.updateByID(id: selectedId ?? 0, todo: todoText, completed: complitedSwitch.isOn, userId: Int32(userIdText) ?? 0) { results in
                if results {
                    let alert = UIAlertController(title: "Todos updated", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
                                       
        }
    }
    
    
}
