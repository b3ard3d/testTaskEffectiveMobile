//
//  TodosEntity.swift
//  testTaskEffectiveMobile
//
//  Created by Роман Кокорев on 26.08.2024.
//

import Foundation
import CoreData

class TodosEntity: NSManagedObject {
    
    class func findOrCreate(_ todos: Todos, context: NSManagedObjectContext) throws -> TodosEntity {
        
        if let todosEntity = try? TodosEntity.find(id: todos.id, context: context) {
            return todosEntity[0]
        } else {
            let todosEntity = TodosEntity(context: context)
            todosEntity.id = todos.id
            todosEntity.todo = todos.todo
            todosEntity.completed = todos.completed
            todosEntity.userId = todos.userId
            todosEntity.creationDate = todos.creationDate
            return todosEntity
        }
    }
    
    class func all(_ context: NSManagedObjectContext) throws -> [TodosEntity] {
        
        let request: NSFetchRequest<TodosEntity> = TodosEntity.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            throw error
        }
    }
    
    class func find(id: Int32, context: NSManagedObjectContext) throws -> [TodosEntity]? {
        
        let request: NSFetchRequest<TodosEntity> = TodosEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let fetchResult = try context.fetch(request)
            if fetchResult.count > 0 {
                assert(fetchResult.count == 1, "Duplicate has been found in DB")
                return fetchResult
            }
        } catch {
            throw error
        }
        
        return nil
    }
}
