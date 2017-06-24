//
//  SelectViewController.swift
//  ARSample
//
//  Created by 根岸裕太 on 2017/06/22.
//  Copyright © 2017年 根岸裕太. All rights reserved.
//

import UIKit

protocol SelectViewControllerDelegate: class {
    func didSelectModel(_ model: ModelName)
}

class SelectViewController: UIViewController {
    
    var delegate: SelectViewControllerDelegate?
    
    @IBOutlet private weak var selectTableView: UITableView!
    
    private let models: Array<ModelName> = [.cube, .desk, .chair]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension SelectViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = models[indexPath.row].rawValue
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectModel(models[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
    
}
