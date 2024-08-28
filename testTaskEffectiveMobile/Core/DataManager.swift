//
//  DataManager.swift
//  testTaskEffectiveMobile
//
//  Created by Роман Кокорев on 26.08.2024.
//

import Foundation

class DataManager {
    let coreDataManager = CoreDataManager.shared
    let networkManager = NetworkManager()
    
    func getAllTodos(_ complitionHander: @escaping ([Todos]) -> Void) {
        coreDataManager.getAllTodos { (todos) in
               if todos.count > 0 {
                   complitionHander(todos)
               } else {
                   
                   self.networkManager.getTodos { (todos) in
                       self.coreDataManager.saveTodos(todos: todos) {
                           complitionHander(todos)
                       }
                   }
               }
           }
       }
    
    func getTodosByID(id: Int32, complitionHander: @escaping ([Todos]) -> Void) {
        coreDataManager.getTodosByID(id: id, complitionHandler: { (todos) in
            if todos.count > 0 {
                complitionHander(todos)
            } else {
                
                self.networkManager.getTodos() { (todos) in
                    self.coreDataManager.saveTodos(todos: todos) {
                        complitionHander(todos)
                    }
                }
            }
        })
    }
}

