//
//  CoreDataManager.swift
//  testTaskEffectiveMobile
//
//  Created by Роман Кокорев on 26.08.2024.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "testTaskEffectiveMobile")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private init() {}
    
    func delAllRecords(in entity: String) -> Void {
        let viewContext = persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
        } catch {
            print("There was an error")
        }
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func deleteAllAndCreateNewDB() {
        let context = persistentContainer.viewContext
        let store = context.persistentStoreCoordinator?.persistentStores.first
        let storeURL = store?.url
        
        do {
            try context.persistentStoreCoordinator?.remove(store!)
            try FileManager.default.removeItem(at: storeURL!)
        } catch {
            print("Error delete DB")
        }
        do {
            try context.persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        } catch {
            print("Error create DB")
        }
    }
    
    func getAllTodos(_ complitionHandler: @escaping ([Todos]) -> Void) {
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            let todosEntities = try? TodosEntity.all(viewContext)
            let dbTodos = todosEntities?.map({ Todos(entity: $0)})
                
            complitionHandler(dbTodos ?? [])
        }
    }
    
    func saveTodos(todos: [Todos], complitionHandler: @escaping () -> Void) {
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            for todo in todos {
                _ = try? TodosEntity.findOrCreate(todo, context: viewContext)
            }
            try? viewContext.save()
            complitionHandler()
        }
    }
    
    func saveTodo(todo: Todos, complitionHandler: @escaping () -> Void) {
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            _ = try? TodosEntity.findOrCreate(todo, context: viewContext)
            try? viewContext.save()
            complitionHandler()
        }
    }
    
    func getTodosByID(id: Int32, complitionHandler: @escaping ([Todos]) -> Void) {
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            let todosEntity = try? TodosEntity.find(id: id, context: viewContext)
            let dbTodosEntity = todosEntity?.map({ Todos(entity: $0)})
                        
            complitionHandler(dbTodosEntity ?? [])
        }
    }
    
    func delTodosByID(id: Int32) -> Void {
        let viewContext = persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<TodosEntity>(entityName: "TodosEntity")
        deleteFetch.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let objects = try viewContext.fetch(deleteFetch)
            for object in objects {
                viewContext.delete(object)
            }
            try viewContext.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func updateByID(id: Int32, todo: String, completed: Bool, userId: Int32, complitionHandler: @escaping (Bool) -> Void) {
        let viewContext = persistentContainer.viewContext
        
        let request: NSFetchRequest<TodosEntity> = TodosEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let fetchResult = try viewContext.fetch(request)
            if fetchResult.count > 0 {
                assert(fetchResult.count == 1, "Duplicate has been found in DB")
                
                if let objectToUpdate = fetchResult.first {
                    objectToUpdate.todo = todo
                    objectToUpdate.completed = completed
                    objectToUpdate.userId = userId
                    try viewContext.save()
                    
                    complitionHandler(true)
                }
            }
        } catch {
            complitionHandler(false)
        }
        complitionHandler(false)
    }
}

