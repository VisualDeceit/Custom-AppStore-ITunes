//
//  AppDetailScreenshotsController.swift
//  iOSArchitecturesDemo
//
//  Created by Alexander Fomin on 26.04.2021.
//  Copyright © 2021 ekireev. All rights reserved.
//

import UIKit

class AppDetailScreenshotsController: UIViewController {
    
    private var appDetailScreenshotsView: AppDetailScreenshotsView {
        return self.view as! AppDetailScreenshotsView
    }
    
    private let app: ITunesApp?
    
    let imageDownloader = ImageDownloader()
    let dispatchGroup = DispatchGroup()
    
    var screenshots: [UIImage] = []
    var contentHeight: CGFloat = 0
    var contentWidth: CGFloat = 0
    
    init(app: ITunesApp?) {
        self.app = app
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = AppDetailScreenshotsView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDetailScreenshotsView.collectionView.dataSource = self
        self.appDetailScreenshotsView.collectionView.delegate = self
        
        getData()
    }
    
    private func getData() {
        app?.screenshotUrls.forEach({ (stringURL) in
            if let ulr = URL(string: stringURL) {
                dispatchGroup.enter()
                imageDownloader.getImage(fromUrl: ulr) { (image, _) in
                    if let image = image {
                        self.screenshots.append(image)
                    }
                    self.dispatchGroup.leave()
                }
            }
        })
        
        dispatchGroup.notify(queue: .main) {
            self.reloadLayouts()
            self.appDetailScreenshotsView.collectionView.reloadData()
        }
    }
    
    private func reloadLayouts() {
        let cropRatio = screenshots.first!.getCropRatio()
        let countMultiplier: CGFloat = cropRatio > 1 ? 1.5 : 1.1
        contentWidth = UIScreen.main.bounds.width / countMultiplier
        contentHeight = contentWidth * cropRatio
        appDetailScreenshotsView.collectionViewHeight.constant = contentHeight
        appDetailScreenshotsView.layoutIfNeeded()
    }
}

extension AppDetailScreenshotsController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        screenshots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScreeshotCell.reuseId, for: indexPath) as! ScreeshotCell
        cell.configure(screenshots[indexPath.item])
        cell.layer.cornerRadius = 12
        cell.layer.masksToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
}
