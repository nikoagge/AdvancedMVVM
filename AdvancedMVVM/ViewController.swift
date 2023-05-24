//
//  ViewController.swift
//  AdvancedMVVM
//
//  Created by Nikos Aggelidis on 16/5/23.
//

import UIKit

protocol TodoView: AnyObject {
    func insertToDoItem() -> ()
    func removeTodoItem(at index: Int) -> ()
    func updateTodoItem(at index: Int) -> ()
    func reloadItems() -> ()
}

class ViewController: UIViewController {
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var itemTextField: UITextField!
    
    let identifier = "todoItemCellIdentifier"
    
    var viewModel: ToDoViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "TodoItemTableViewCell", bundle: nil)
        itemsTableView.register(nib, forCellReuseIdentifier: identifier)
        
        viewModel = ToDoViewModel(todoView: self)
    }

    @IBAction func onAddItem(_ sender: UIButton) {
        guard let newToDoValue = itemTextField.text, !newToDoValue.isEmpty else {
            debugPrint("No value entered")
            
            return
        }
        
        viewModel?.newToDoItem = newToDoValue
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.viewModel?.onAddToDoItem()
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ToDoItemTableViewCell else { return UITableViewCell() }
        let itemViewModel = viewModel?.items[indexPath.row]
        cell.configure(withViewModel: itemViewModel!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemViewModel = viewModel?.items[indexPath.row]
        (itemViewModel as? TodoItemViewDelegate)?.onItemSelected()
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let itemViewModel = viewModel?.items[indexPath.row]
        var menuActions: [UIContextualAction] = []
        _ = itemViewModel?.menuItems?.map { menuItem in
            let menuAction = UIContextualAction(style: .normal, title: menuItem.title!) { (action, sourceView, success: (Bool) -> (Void)) in
                if let delegate = menuItem as? TodoMenuItemViewDelegate {
                    DispatchQueue.global(qos: .background).async {                        delegate.onMenuItemSelected()
                    }
                }
                success(true)
            }
            menuAction.backgroundColor = menuItem.backColor!.hexColor
            menuActions.append(menuAction)
        }
        
        return UISwipeActionsConfiguration(actions: menuActions)
    }
}

extension ViewController: TodoView {
    func insertToDoItem() {
        guard let items = viewModel?.items else {
            debugPrint("Items object is empty")
            
            return
        }
        
        itemTextField.text = viewModel?.newToDoItem ?? ""
        
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.itemsTableView.beginUpdates()
            self.itemsTableView.insertRows(at: [IndexPath(row: items.count-1, section: 0)], with: .automatic)
            self.itemsTableView.endUpdates()
        }
    }
    
    func removeTodoItem(at index: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.itemsTableView.beginUpdates()
            self.itemsTableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.itemsTableView.endUpdates()
        }
    }

    func updateTodoItem(at index: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.itemsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self.viewModel?.todoView?.updateTodoItem(at: index)
        }
    }

    func reloadItems() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.itemsTableView.reloadData()
        }
    }
}
