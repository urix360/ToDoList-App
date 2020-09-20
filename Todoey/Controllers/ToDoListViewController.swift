//
//  ViewController.swift
//  Todoey


import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {

    var items: Results<Item>?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
    }
    override func viewWillAppear(_ animated: Bool) {
        if let colour = selectedCategory?.color{
        navigationController?.navigationBar.standardAppearance.backgroundColor = UIColor(hexString: colour)
            searchBar.barTintColor = UIColor(hexString: colour)?.lighten(byPercentage: 0.1)
        }
    }
    
    // MARK: - Table view
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = items?[indexPath.row]{
        cell.textLabel?.text = item.title
            cell.backgroundColor = HexColor(selectedCategory!.color)!.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(items!.count))
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        cell.accessoryType = item.done ? .checkmark : .none
        //if itemArray[indexPath.row].done == true {
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do{
            try realm.write{
            items![indexPath.row].done = !items![indexPath.row].done
            }
        }
        catch{
            print(error)
        }
        tableView.reloadData()
        
    }
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new item", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let text = textField.text, let category = self.selectedCategory{
                do{
                    try self.realm.write(){
                        let newItem = Item()
                        newItem.title=text
                        newItem.dateCreated = Date()
                        category.items.append(newItem)
                    }
                }
                    catch{
                        print(error)
                    }
                }
            self.tableView.reloadData()
        }
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "create new item"
            textField = alertTextField
        }
        present(alert, animated: true)
    }
    
    // MARK: - DataBase
    
    func loadItems(){
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
            }
    
    override func updateData(indexPath: IndexPath) {
        if let item = self.items?[indexPath.row]{
        do{
                try self.realm.write{
                    realm.delete(item)
            }
        }
            catch{
                print("faild to update \(error)")
            }
        }
    }
    }


extension ToDoListViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.items = items?.filter("title CONTAINS[cd] %@",searchBar.text).sorted(byKeyPath: "dateCreated", ascending: true)
        searchBar.endEditing(true)
        tableView.reloadData()
        }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            self.loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
    
}
    
    



