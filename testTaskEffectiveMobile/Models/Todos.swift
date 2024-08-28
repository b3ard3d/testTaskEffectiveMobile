//
//  Todos.swift
//  testTaskEffectiveMobile
//
//  Created by Роман Кокорев on 26.08.2024.
//

import Foundation

struct JsonTodos: Codable {
    let todos: [Todos]
}

struct Todos: Codable {
    
    var id: Int32
    var todo: String
    var completed: Bool
    var userId: Int32
    var creationDate: Date
    
    init(id: Int32, todo: String, completed: Bool, userId: Int32) {
        self.id = id
        self.todo = todo
        self.completed = completed
        self.userId = userId
        self.creationDate = returnCurrentDate()
    }
    
    init(entity: TodosEntity) {
        self.id = entity.id
        self.todo = entity.todo ?? ""
        self.completed = entity.completed
        self.userId = entity.userId
        self.creationDate = returnCurrentDate()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int32.self, forKey: .id)
        self.todo = try container.decode(String.self, forKey: .todo)
        self.completed = try container.decode(Bool.self, forKey: .completed)
        self.userId = try container.decode(Int32.self, forKey: .userId)
        self.creationDate = returnCurrentDate()
    }
}

func returnCurrentDate() -> Date {
    let currentDate = Date()
    return currentDate
}
