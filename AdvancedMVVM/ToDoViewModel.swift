//
//  ToDoViewModel.swift
//  AdvancedMVVM
//
//  Created by Nikos Aggelidis on 16/5/23.
//

import RxSwift

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
    
    init() {
        let item1 = ToDoItemViewModel(id: "1", textValue: "Washing Clothes", parentViewModel: self)
        let item2 = ToDoItemViewModel(id: "2", textValue: "Buy Groceries", parentViewModel: self)
        let item3 = ToDoItemViewModel(id: "3", textValue: "Wash car", parentViewModel: self)
        items.value.append(contentsOf: [item1, item2, item3])
    }
}

extension ToDoViewModel: TodoViewDelegate {
    func onAddToDoItem() {
        guard let newValue = newToDoItem else {
            debugPrint("New value is empty")
            
            return
        }
        debugPrint("New value received: \(newValue)")
        
        let newItemIndex = items.value.count + 1
        let newItem = ToDoItemViewModel(id: "\(newItemIndex)", textValue: newValue, parentViewModel: self)
        items.value.append(newItem)
        
        newToDoItem = ""        
    }
    
    func onTodoDelete(for id: String) {
        guard let index = items.value.index(where : { $0.id! == id }) else {
            return
        }
        items.value.remove(at: index)
    }
    
    func onToDoDone(for id: String) {
        guard let index = items.value.index(where : { $0.id! == id }) else {
            return
        }
        var todoItem = items.value[index]
        todoItem.isDone! = !todoItem.isDone!
        if var doneMenuItem = todoItem.menuItems?.filter { (todoMenuItem) -> Bool in
            todoMenuItem is DoneMenuItemViewModel
        }.first {
            doneMenuItem.title = todoItem.isDone! ? "Undone" : "Done"
        }

        items.value.sorted(by: {
            if !($0.isDone ?? false) && !($1.isDone ?? false) {
                return ($0.id ?? "") < ($1.id ?? "")
            }

            if ($0.isDone ?? false) && ($1.isDone ?? false) {
                return ($0.id ?? "") < ($1.id ?? "")
            }

            return !(($0.isDone ?? false) && ($1.isDone ?? false))
        })
    }
}
