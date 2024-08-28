//
//  ViewController.swift
//  testTaskEffectiveMobile
//
//  Created by Роман Кокорев on 26.08.2024.
//

import UIKit

class MainViewController: UIViewController {
    
    var todos = [Todos]()
    
    let dataManager = DataManager()
    let networkManager = NetworkManager()
    let coreDataManager = CoreDataManager.shared

    private lazy var tableViewTodos: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupConstraint()
        updateTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTableView()
    }
    
    func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableViewTodos)
    }
    
    private func setupNavigationBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.title = "Todos"
        navigationItem.backButtonTitle = "Back"
        
        let rightBarButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addTodosButtonClicked))
        
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func setupConstraint() {
        NSLayoutConstraint.activate([
            tableViewTodos.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableViewTodos.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableViewTodos.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableViewTodos.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func updateTableView() {
        dataManager.getAllTodos() { [self] todos in
            self.todos = todos
            self.todos.sort { $0.id < $1.id }
            self.tableViewTodos.reloadData()
        }
    }
    
    @objc func addTodosButtonClicked() {
        let alert = UIAlertController(title: "Add new todos?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            let addTodosViewController = AddTodosViewController()
            addTodosViewController.lastId = self.todos.last?.id
            self.navigationController?.pushViewController(addTodosViewController, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let todos = todos[indexPath.row]
        cell.textLabel?.text = (String(indexPath.row + 1)) + ": " + (todos.todo)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row != 0 {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
                (contextualAction, view, boolValue) in
                self.todos.remove(at: indexPath.row - 1)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.coreDataManager.delTodosByID(id: self.todos[indexPath.row - 1].id)
            }
            let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
            return swipeActions
        }
        else { return nil }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = EditingTodosViewController()
        viewController.selectedId = todos[indexPath.row].id
        viewController.selectedUserId = todos[indexPath.row].userId
        viewController.selectedTodo = todos[indexPath.row].todo
        viewController.selectedCompleted = todos[indexPath.row].completed
        viewController.selectedCreationDate = todos[indexPath.row].creationDate
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}

