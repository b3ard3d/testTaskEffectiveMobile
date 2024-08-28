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
    
    func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableViewTodos)
    }
    
    private func setupNavigationBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.title = "Задачи"
        navigationItem.backButtonTitle = ""
        
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
        let alert = UIAlertController(title: "Хотите добавить новую задачу?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { action in
            let addTodosViewController = AddTodosViewController()
            //addTodosViewController.selectedUUID = self.selectedUUID
            //self.present(addTodosViewController, animated: true)
            self.navigationController?.pushViewController(addTodosViewController, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Нет", style: .default, handler: nil))
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
        //cell.textLabel?.text = (String(todos.id)) + ": " + (todos.todo)
        cell.textLabel?.text = (String(indexPath.row + 1)) + ": " + (todos.todo)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row != 0 {
            let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") {
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
    
 /*   func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        headerView.backgroundColor = .systemBackground
        
            let label = UILabel()
            label.frame = CGRect.init(x: 20, y: 5, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
            label.text = "Контактная информация:"
            
            let addContactInfoButton = UIButton.init(frame: CGRect(x: (headerView.frame.width / 2) - 20, y: 5, width: headerView.frame.width - 10, height: headerView.frame.height - 10))
            addContactInfoButton.setImage(UIImage(systemName: "plus"), for: .normal)
            addContactInfoButton.addTarget(self, action: #selector(addTodosButtonClicked), for: .touchUpInside)
                    
            headerView.addSubview(label)
            headerView.addSubview(addContactInfoButton)
                    
        return headerView
    }   */
    
/*    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableViewContactPerson {
            let viewController = DetailsContactPersonCounterpartiesViewController()
            viewController.selectedFullName = contactPersonCounterparties[indexPath.row].name
            viewController.selectedUUID = contactPersonCounterparties[indexPath.row].uuid
            
            navigationController?.pushViewController(viewController, animated: true)
        } else if tableView == tableViewContact {
            let viewController = ContactInfoViewController()
            viewController.selectedKind = contactDetailsCounterparties[indexPath.row].kind
            viewController.selectedPresentation = contactDetailsCounterparties[indexPath.row].presentation
            
            navigationController?.pushViewController(viewController, animated: true)
        }
    }   */
}

