//
//  TodoItem.swift
//  AdvancedMVVM
//
//  Created by Nikos Aggelidis on 25/5/23.
//

import RealmSwift

class TodoItem: Object {
    @objc dynamic var todoId: Int = 0
    @objc dynamic var todoValue: String = ""
    @objc dynamic var isDone: Bool = false
    @objc dynamic var createdAt: Date? = Date()
    @objc dynamic var updatedAt: Date?
    @objc dynamic var deletedAt: Date?
    
    init(todoId: Int, todoValue: String, isDone: Bool, createdAt: Date? = nil, updatedAt: Date? = nil, deletedAt: Date? = nil) {
        self.todoId = todoId
        self.todoValue = todoValue
        self.isDone = isDone
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
    
    override static func primaryKey() -> String? {
        return "todoId"
    }
}
