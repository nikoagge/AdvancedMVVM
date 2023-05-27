//
//  RealmDatabase.swift
//  AdvancedMVVM
//
//  Created by Nikos Aggelidis on 25/5/23.
//

import RealmSwift

class RealmDatabase {
    static let shared = RealmDatabase()
    
    private init() { }
    
    func createOrUpdate(toDoItemValue: String) -> (Void) {
        let realm = try! Realm()
        var todoId: Int? = 1
        if let lastEntity = realm.objects(TodoItem.self).last {
            todoId = lastEntity.todoId + 1
        }
        let todoItemEntity = TodoItem()
        todoItemEntity.todoId = todoId ?? 1
        todoItemEntity.todoValue = toDoItemValue
        try! realm.write {
            realm.add(todoItemEntity, update: .all)
        }
    }
    
    func fetch() -> (Results<TodoItem>) {
        let realm = try! Realm()
        let todoItemResults = realm.objects(TodoItem.self)
        
        return todoItemResults
    }
    
    func softDelete(primaryKey: Int) -> (Void) {
        let realm = try! Realm()
        
        if let todoItemEntity = realm.object(ofType: TodoItem.self, forPrimaryKey: primaryKey) {
            try! realm.write {
                todoItemEntity.deletedAt = Date()
            }
        }
    }
    
    func delete(primaryKey: Int) -> (Void) {
        let realm = try! Realm()
        
        if let todoItemEntity = realm.object(ofType: TodoItem.self, forPrimaryKey: primaryKey) {
            try! realm.write {
                realm.delete(todoItemEntity)
            }
        }
    }
    
    func isDone(primaryKey: Int) -> (Void) {
        let realm = try! Realm()
        
        if let todoItemEntity = realm.object(ofType: TodoItem.self, forPrimaryKey: primaryKey) {
            try! realm.write {
                todoItemEntity.isDone = !todoItemEntity.isDone
            }
        }
    }
}
