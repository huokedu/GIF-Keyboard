//
//  KeyboardViewController.swift
//  AdventKeyboard
//
//  Created by Romain Pouclet on 2015-11-28.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import SwiftGifiOS
import YLGIFImage
import MobileCoreServices;

class KeyboardViewController: UIInputViewController {
    let gifView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    var gifs: [NSURL] = []
    let toolbar = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let switchKeyboardButton = UIButton(type: .Custom)
        switchKeyboardButton.setImage(UIImage(named: "switch"), forState: .Normal)
        switchKeyboardButton.imageView?.contentMode = .ScaleAspectFit
        switchKeyboardButton.addTarget(self, action: Selector("didTapSwitchButton:"), forControlEvents: .TouchUpInside)
        switchKeyboardButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        toolbar.addArrangedSubview(switchKeyboardButton)
        
        let deleteKeyboardButton = UIButton(type: .Custom)
        deleteKeyboardButton.setImage(UIImage(named: "delete"), forState: .Normal)
        deleteKeyboardButton.imageView?.contentMode = .ScaleAspectFit
        deleteKeyboardButton.addTarget(self, action: Selector("didTapDeleteButton:"), forControlEvents: .TouchUpInside)
        deleteKeyboardButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        toolbar.addArrangedSubview(deleteKeyboardButton)

        view.addSubview(toolbar)
        toolbar.axis = .Horizontal
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.heightAnchor.constraintEqualToConstant(40).active = true
        toolbar.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        toolbar.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        toolbar.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
        toolbar.distribution = .FillEqually
        let layout = gifView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: 105, height: 60)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        gifView.registerClass(ImageCell.self, forCellWithReuseIdentifier: "GIFCell")
        gifView.dataSource = self
        gifView.delegate = self

        view.addSubview(gifView)
        gifView.translatesAutoresizingMaskIntoConstraints = false
        gifView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        gifView.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        gifView.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
        gifView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -40).active = true
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let manager = NSFileManager.defaultManager()
        
        let directory = manager.containerURLForSecurityApplicationGroupIdentifier("group.perfectly-cooked.adventcalendar")!
        let gifs = manager.enumeratorAtURL(directory, includingPropertiesForKeys: nil, options: [.SkipsSubdirectoryDescendants, .SkipsHiddenFiles]) { (url, error) -> Bool in
            return true
        }!.allObjects as! [NSURL]
        
        self.gifs = gifs.filter({ $0.pathExtension == "gif" })
        self.gifView.reloadData()
    }
    
    func didTapDeleteButton(sender: UIButton) {
        textDocumentProxy.deleteBackward()
    }
    
    func didTapSwitchButton(sender: UIButton) {
        advanceToNextInputMode()
    }
}

extension KeyboardViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ImageCell else { return }
        
        let gif = gifs[indexPath.row]
        if let data = NSData(contentsOfURL: gif) {
            UIPasteboard.generalPasteboard().setData(data, forPasteboardType: kUTTypeGIF as String)
        }

        cell.showCopied()
    }
}

extension KeyboardViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GIFCell", forIndexPath: indexPath) as! ImageCell
        let gif = gifs[indexPath.row]
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            if let data = NSData(contentsOfURL: gif) {
                dispatch_async(dispatch_get_main_queue()) {
                    let localCell = collectionView.cellForItemAtIndexPath(indexPath) as! ImageCell
                    localCell.imageView.image = UIImage(data: data)
                }
            }
        }
        
        return cell
    }
}
