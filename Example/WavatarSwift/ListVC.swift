//
//  ViewController.swift
//  WavatarSwift
//
//  Created by Anton Serebryakov on 09/29/2017.
//  Copyright (c) 2017 Anton Serebryakov. All rights reserved.
//

import UIKit
import WavatarSwift
import SwiftHash

class ListVC: UITableViewController {
    
    private var data: [String] = [
        ListVC.randomEmail(),
        "my@mail.ru",
        "N1сkN@mе",
        "+7(987)123-45-67",
        "Rick Sanchez",
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
    ]
    
    static func randomEmail() -> String {
        let len = 2 + arc4random() % 2
        var chars: [Character] = []
        let a = ("a" as UnicodeScalar).value
        for _ in 0..<len {
            if let chRaw = UnicodeScalar(a + (arc4random() % 26)) {
                chars.append(Character(chRaw))
            }
        }
        return String(chars) + "@gmail.com"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wavatars"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshAction))
        tableView.tableFooterView = UIView()
        registerTableViewClasses()
    }
    
    @objc
    private func refreshAction() {
        let row = 0
        if data.count > 0 {
            data[row] = ListVC.randomEmail()
        } else {
            data.append(ListVC.randomEmail())
        }
        tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
    }
    
    private let MyHeaderId = "MyHeaderId"
    private let MyCellId = "MyCellId"
    
    private func registerTableViewClasses() {
        tableView.register(MyHeader.self, forHeaderFooterViewReuseIdentifier: MyHeaderId)
        tableView.register(MyCell.self, forCellReuseIdentifier: MyCellId)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: MyHeaderId) as! MyHeader
        view.firstLabel.text = "Local"
        view.secondLabel.text = "Gravatar"
        return view
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let string = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: MyCellId, for: indexPath) as! MyCell
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = string
        cell.imageView?.image = WavatarSwift.generate(string: string, size: 50)
        cell.loadGravatarImage(for: string)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let string = data[indexPath.row]
        let detailVC = DetailVC(string: string)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    
    // MARK: - Header
    
    private class MyHeader: UITableViewHeaderFooterView {
        
        override func layoutSubviews() {
            super.layoutSubviews()
            let hgt = self.contentView.bounds.size.height
            var offsetX: CGFloat = 0
            offsetX += 10
            firstLabel.frame = CGRect(x: offsetX, y: 0, width: 50, height: hgt)
            offsetX += 50 + 10
            secondLabel.frame = CGRect(x: offsetX, y: 0, width: 50, height: hgt)
        }

        lazy var firstLabel: UILabel = {
            let v = UILabel()
            v.font = UIFont.systemFont(ofSize: 12)
            v.textColor = .gray
            v.textAlignment = .center
            self.contentView.addSubview(v)
            return v
        }()
        
        lazy var secondLabel: UILabel = {
            let v = UILabel()
            v.font = UIFont.systemFont(ofSize: 12)
            v.textColor = .gray
            v.textAlignment = .center
            self.contentView.addSubview(v)
            return v
        }()
        
    }
    
    
    // MARK: - Cell
    
    private class MyCell: UITableViewCell {
        
        override func layoutSubviews() {
            super.layoutSubviews()
            let wdt = self.contentView.bounds.size.width
            let hgt = self.contentView.bounds.size.height
            var offsetX: CGFloat = 0
            offsetX += 10
            imageView?.frame = CGRect(x: offsetX, y: rint((hgt - 50) / 2), width: 50, height: 50)
            offsetX += 50 + 10
            gravatarView.frame = CGRect(x: offsetX, y: rint((hgt - 50) / 2), width: 50, height: 50)
            offsetX += 50 + 10
            textLabel?.frame = CGRect(x: offsetX, y: 10, width: wdt - (offsetX + 10), height: hgt - 2 * 10)
        }
        
        lazy var gravatarView: UIImageView = {
            let v = UIImageView()
            self.indicatorView.frame = v.bounds
            v.addSubview(self.indicatorView)
            v.backgroundColor = UIColor(white: 0.9, alpha: 1)
            self.imageView?.backgroundColor = v.backgroundColor
            self.contentView.addSubview(v)
            return v
        }()
        
        lazy var indicatorView: UIActivityIndicatorView = {
            let v = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            v.contentMode = .center
            v.stopAnimating()
            return v
        }()
        
        private var requestedGravatarHash: String?
        func loadGravatarImage(for string: String) {
            let hash = WavatarSwift.hash(string)
            print("\(hash ?? "nil") <- “\(string)”")
            let gravatarHash = MD5(string).lowercased()
            requestedGravatarHash = gravatarHash
            gravatarView.image = nil
            indicatorView.startAnimating()
            DispatchQueue.global(qos: .background).async {
                [weak self] in
                let image: UIImage?
                if let url = URL(string: "https://www.gravatar.com/avatar/\(gravatarHash)?d=wavatar"),
                    let data = try? Data(contentsOf: url) {
                    image = UIImage(data: data)
                } else {
                    image = nil
                }
                DispatchQueue.main.async {
                    guard let this = self else {
                        return
                    }
                    if this.requestedGravatarHash == gravatarHash {
                        this.indicatorView.stopAnimating()
                        this.gravatarView.image = image
                    }
                }
            }
        }
        
    }
    
}

