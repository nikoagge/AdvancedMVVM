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
    
    override static func primaryKey() -> String? {
        return "todoId"
    }
}
