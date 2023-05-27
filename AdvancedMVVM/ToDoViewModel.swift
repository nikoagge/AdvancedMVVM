//
//  ToDoViewModel.swift
//  AdvancedMVVM
//
//  Created by Nikos Aggelidis on 16/5/23.
//

import RxSwift
import RealmSwift

protocol TodoMenuItemViewPresentable {
    var title: String? { get set }
    var backColor: String? { get }
}

protocol TodoMenuItemViewDelegate {
    func onMenuItemSelected() -> ()
}

class TodoMenuItemViewModel: TodoMenuItemViewPresentable, TodoMenuItemViewDelegate {
    var title: String?
    var backColor: String?
    weak var parent: TodoItemViewDelegate?
    
    init(parentViewModel: TodoItemViewDelegate) {
        self.parent = parentViewModel
    }
    
    func onMenuItemSelected() {
        //Base class does not require an implementation
    }
}

class RemoveMenuItemViewModel: TodoMenuItemViewModel {
    override func onMenuItemSelected() {
        debugPrint("Remove menu item selected")
        parent?.onRemoveSelected()
    }
}

class DoneMenuItemViewModel: TodoMenuItemViewModel {
    override func onMenuItemSelected() {
        debugPrint("Done menu item selected")
        parent?.onDoneSelected()
    }
}

protocol TodoItemViewDelegate: AnyObject {
    func onItemSelected() -> (Void)
    func onRemoveSelected() -> (Void)
    func onDoneSelected() -> (Void)
}

protocol ToDoItemPresentable {
    var id: String? { get }
    var textValue: String? { get }
    var isDone: Bool? { get set }
    var menuItems: [TodoMenuItemViewPresentable]? { get }
}

class ToDoItemViewModel: ToDoItemPresentable {
    var id: String? = "0"
    var textValue: String?
    var isDone: Bool? = false
    var menuItems: [TodoMenuItemViewPresentable]? = []
    weak var parent: TodoViewDelegate?
    
    init(id: String? = nil, textValue: String? = nil, parentViewModel: TodoViewDelegate) {
        self.id = id
        self.textValue = textValue
        self.parent = parentViewModel
        
        let removeMenuItem = RemoveMenuItemViewModel(parentViewModel: self)
        removeMenuItem.title = "Remove"
        removeMenuItem.backColor = "ff0000"
        
        let doneMenuItem = DoneMenuItemViewModel(parentViewModel: self)
        doneMenuItem.title = isDone! ? "Undone" : "Done"
        doneMenuItem.backColor = "008000"
        
        menuItems?.append(contentsOf: [removeMenuItem, doneMenuItem])
    }
}

extension ToDoItemViewModel: TodoItemViewDelegate {
    func onItemSelected() {
        debugPrint("Item selected with id: \(id ?? "")")
    }
    
    func onDoneSelected() {
        parent?.onToDoDone(for: id ?? "")
    }
    
    func onRemoveSelected() {
        parent?.onTodoDelete(for: id ?? "")
    }
}

protocol TodoViewDelegate: AnyObject {
    func onAddToDoItem() -> ()
    func onTodoDelete(for id: String) -> ()
    func onToDoDone(for id: String) -> ()
}

protocol TodoViewPresentable {
    var newToDoItem: String? { get }
}

class ToDoViewModel: TodoViewPresentable {
    weak var todoView: TodoView?
    var newToDoItem: String?
    var items: Variable<[ToDoItemPresentable]> = Variable([])
    var realmDatabase: RealmDatabase?
    var notificationToken: NotificationToken? = nil
    
    init() {
        realmDatabase = RealmDatabase.shared
        let todoItemResults = realmDatabase?.fetch()
        notificationToken = todoItemResults?.observe({ [weak self] (changes: RealmCollectionChange) in
            guard let self = self else { return }
            
            switch changes {
            case .initial:
                todoItemResults?.forEach({ todoItemEntity in
                    let todoItemEntity = todoItemEntity
                    let newItemIndex = todoItemEntity.todoId
                    let newValue = todoItemEntity.todoValue
                    
                    let newItem = ToDoItemViewModel(id: "\(newItemIndex)", textValue: newValue, parentViewModel: self)
                    self.items.value.append(newItem)
                })
                
            case .update(_, let deletions, let insertions, let modifications):
                insertions.forEach { index in
                    let todoItemEntity = todoItemResults?[index]
                    
                    let newItemIndex = todoItemEntity?.todoId
                    let newValue = todoItemEntity?.todoValue
                    
                    let newItem = ToDoItemViewModel(id: "\(newItemIndex)", textValue: newValue, parentViewModel: self)
                    self.items.value.append(newItem)
                }
                
                modifications.forEach { [weak self] index in
                    guard let self = self else { return }
                    let todoItemEntity = todoItemResults?[index]
                    
                    guard let index = self.items.value.index(where : { Int($0.id!) == todoItemEntity?.todoId }) else {
                        return
                    }
                    
                    if todoItemEntity?.deletedAt != nil {
                        self.items.value.remove(at: index)
                        realmDatabase?.delete(primaryKey: todoItemEntity?.todoId ?? 0)
                    } else {
                        var todoItemViewModel = self.items.value[index]
                        todoItemViewModel.isDone = todoItemEntity?.isDone
                        
                        if var doneMenuItem = todoItemViewModel.menuItems?.filter { (todoMenuItem) -> Bool in
                            todoMenuItem is DoneMenuItemViewModel
                        }.first {
                            doneMenuItem.title = todoItemEntity?.isDone ?? false ? "Undone" : "Done"
                        }
                    }
                    
                    var todoItemViewModel = self.items.value[index]
                    
                    todoItemViewModel.isDone! = ((todoItemEntity?.isDone) != nil)
                    if var doneMenuItem = todoItemViewModel.menuItems?.filter { (todoMenuItem) -> Bool in
                        todoMenuItem is DoneMenuItemViewModel
                    }.first {
                        doneMenuItem.title = todoItemEntity?.isDone! ? "Undone" : "Done"
                    }
                }
                
            case .error(let error):
                break
            }
            
            self.items.value.sort(by: {
                if !($0.isDone ?? false) && !($1.isDone ?? false) {
                    return ($0.id ?? "") < ($1.id ?? "")
                }

                if ($0.isDone ?? false) && ($1.isDone ?? false) {
                    return ($0.id ?? "") < ($1.id ?? "")
                }

                return !(($0.isDone ?? false) && ($1.isDone ?? false))
            })
        })
    }
    
    deinit {
        notificationToken?.invalidate()
    }
}

extension ToDoViewModel: TodoViewDelegate {
    func onAddToDoItem() {
        guard let newValue = newToDoItem else {
            debugPrint("New value is empty")
            
            return
        }
        debugPrint("New value received: \(newValue)")
        realmDatabase?.createOrUpdate(toDoItemValue: newValue)
        newToDoItem = ""
    }
    
    func onTodoDelete(for id: String) {
        realmDatabase?.softDelete(primaryKey: Int(id) ?? 0)
    }
    
    func onToDoDone(for todoId: String) {
        realmDatabase?.isDone(primaryKey: Int(todoId) ?? 0)
    }
}
