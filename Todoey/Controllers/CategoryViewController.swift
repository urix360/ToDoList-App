

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()

    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        loadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.standardAppearance.backgroundColor = UIColor(hexString: "1D9BF6")
    }

    // MARK: - Table view

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let correntCategory = categories?[indexPath.row]{
        cell.textLabel?.text = correntCategory.name
            cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.init(hexString: correntCategory.color)
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationCV = segue.destination as! ToDoListViewController
        destinationCV.selectedCategory = categories?[tableView.indexPathForSelectedRow!.row]
    }
    
    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new item", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let text = textField.text{
                let newCategory = Category()
                newCategory.name = text
                newCategory.color = UIColor.randomFlat().hexValue()
                self.saveData(newCategory)
                }
        }
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "creat new Category"
            textField = alertTextField
        }
        present(alert, animated: true)
    }
    
    // MARK: - DataBase
    
    func saveData(_ category: Category){
        do{
            try realm.write{
                realm.add(category)
            }
        }
        catch{
            print("faild to save data \(error)")
        }
        tableView.reloadData()
    }
    
    func loadData(){
       categories = realm.objects(Category.self)
       tableView.reloadData()
        }
    
    override func updateData(indexPath: IndexPath) {
        if let category = self.categories?[indexPath.row]{
        do{
                try self.realm.write{
                    realm.delete(category)
                    
            }
        }
            catch{
                print("faild to update \(error)")
            }
        }
    }
}

