//
//  MainTableViewController.swift
//  iGif
//
//  Created by Junior B. on 01.02.17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit
import RxSwift
import SwiftyJSON

class MainTableViewController: UITableViewController {
  
  let searchController = UISearchController(searchResultsController: nil)
  let bag = DisposeBag()
  var gifs = [JSON]()
  let search = BehaviorSubject(value: "")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "iGif"
    
    searchController.searchResultsUpdater = self
//    searchController.dimsBackgroundDuringPresentation = false
    searchController.obscuresBackgroundDuringPresentation = false
    definesPresentationContext = true
    tableView.tableHeaderView = searchController.searchBar
    
    search.filter { $0.count >= 3 }
      .throttle(.milliseconds(1000), scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .flatMapLatest { query -> Observable<[JSON]> in
        return ApiController.shared.search(text: query)
          .catchAndReturn([])
      }
      .observe(on: MainScheduler.instance)
      .subscribe(onNext: { result in
        self.gifs = result
        self.tableView.reloadData()
      })
      .disposed(by:bag)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return gifs.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "GifCell", for: indexPath) as! GifTableViewCell
  
    let gif = gifs[indexPath.row]
    print("gif url :: ")
    if let url = gif["images"]["fixed_height"]["url"].string {
      cell.downloadAndDisplay(gif: url)
    }
    
    return cell
  }

}

extension MainTableViewController: UISearchResultsUpdating {
  
  public func updateSearchResults(for searchController: UISearchController) {
    search.onNext(searchController.searchBar.text ?? "")
  }
  
}
