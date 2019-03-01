//
//  ViewController.swift
//  FluidPhoto
//
//  Created by UetaMasamichi on 2016/12/23.
//  Copyright © 2016 Masmichi Ueta. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var i = 0
    
    private let photos = [
        #imageLiteral(resourceName: "1"),
        #imageLiteral(resourceName: "2"),
        #imageLiteral(resourceName: "3"),
        #imageLiteral(resourceName: "4"),
        #imageLiteral(resourceName: "5"),
        #imageLiteral(resourceName: "6"),
        #imageLiteral(resourceName: "7"),
        #imageLiteral(resourceName: "8"),
        #imageLiteral(resourceName: "9"),
        #imageLiteral(resourceName: "10"),
        #imageLiteral(resourceName: "11"),
        #imageLiteral(resourceName: "12"),
        #imageLiteral(resourceName: "13"),
        #imageLiteral(resourceName: "14"),
        #imageLiteral(resourceName: "15"),
        #imageLiteral(resourceName: "16"),
        #imageLiteral(resourceName: "17"),
        #imageLiteral(resourceName: "18"),
        #imageLiteral(resourceName: "1"),
        #imageLiteral(resourceName: "2"),
        #imageLiteral(resourceName: "3"),
        #imageLiteral(resourceName: "4"),
        #imageLiteral(resourceName: "5"),
        #imageLiteral(resourceName: "6"),
        #imageLiteral(resourceName: "7"),
        #imageLiteral(resourceName: "8"),
        #imageLiteral(resourceName: "9"),
        #imageLiteral(resourceName: "10"),
        #imageLiteral(resourceName: "11"),
        #imageLiteral(resourceName: "12"),
        #imageLiteral(resourceName: "13"),
        #imageLiteral(resourceName: "14"),
        #imageLiteral(resourceName: "15"),
        #imageLiteral(resourceName: "16"),
        #imageLiteral(resourceName: "17"),
        #imageLiteral(resourceName: "18")
    ]
    
    var selectedIndexPath: IndexPath!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ShowPhotoPageView" {
//            let nav = navigationController
//            let vc = segue.destination as! PhotoPageContainerViewController
//            nav?.delegate = vc.transitionController
//            vc.transitionController.fromDelegate = self
//            vc.transitionController.toDelegate = vc
//            vc.currentIndex = selectedIndexPath.row
//            vc.photos = photos
//        }
    }
    
    @IBAction func backToViewController(segue: UIStoryboardSegue) {
        
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(PhotoCollectionViewCell.self)", for: indexPath) as! PhotoCollectionViewCell
        
        cell.imageView.image = photos[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        
        let vc = PhotoZoomViewController(image: photos[selectedIndexPath.row], originalImageIsRounded: true, presenter: self)
        

        
        navigationController!.pushViewController(vc, animated: true)
        
    //    performSegue(withIdentifier: "ShowPhotoPageView", sender: self)
    }
    
    //This function prevents the collectionView from accessing a deallocated cell. In the event
    //that the cell for the selectedIndexPath is nil, a default UIImageView is returned in its place
    func getImageViewFromCollectionViewCell(for selectedIndexPath: IndexPath) -> UIImageView {
        
        //Get the array of visible cells in the collectionView
        let visibleCells = collectionView.indexPathsForVisibleItems
        
        //If the current indexPath is not visible in the collectionView,
        //scroll the collectionView to the cell to prevent it from returning a nil value
        if !visibleCells.contains(selectedIndexPath) {
           
            //Scroll the collectionView to the current selectedIndexPath which is offscreen
            collectionView.scrollToItem(at: selectedIndexPath, at: .centeredVertically, animated: false)
            
            //Reload the items at the newly visible indexPaths
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
            collectionView.layoutIfNeeded()
            
            //Guard against nil values
            guard let guardedCell = (collectionView.cellForItem(at: selectedIndexPath) as? PhotoCollectionViewCell) else {
                //Return a default UIImageView
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
            }
            //The PhotoCollectionViewCell was found in the collectionView, return the image
            return guardedCell.imageView
        }
        else {
            
            //Guard against nil return values
            guard let guardedCell = collectionView.cellForItem(at: selectedIndexPath) as? PhotoCollectionViewCell else {
                //Return a default UIImageView
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
            }
            //The PhotoCollectionViewCell was found in the collectionView, return the image
            return guardedCell.imageView
        }
        
    }
    
    //This function prevents the collectionView from accessing a deallocated cell. In the
    //event that the cell for the selectedIndexPath is nil, a default CGRect is returned in its place
    func getFrameFromCollectionViewCell(for selectedIndexPath: IndexPath) -> CGRect {
        
        //Get the currently visible cells from the collectionView
        let visibleCells = collectionView.indexPathsForVisibleItems
        
        //If the current indexPath is not visible in the collectionView,
        //scroll the collectionView to the cell to prevent it from returning a nil value
        if !visibleCells.contains(selectedIndexPath) {
            
            //Scroll the collectionView to the cell that is currently offscreen
            collectionView.scrollToItem(at: selectedIndexPath, at: .centeredVertically, animated: false)
            
            //Reload the items at the newly visible indexPaths
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
            collectionView.layoutIfNeeded()
            
            //Prevent the collectionView from returning a nil value
            guard let guardedCell = (collectionView.cellForItem(at: selectedIndexPath) as? PhotoCollectionViewCell) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
            }
            
            return guardedCell.frame
        }
        //Otherwise the cell should be visible
        else {
            //Prevent the collectionView from returning a nil value
            guard let guardedCell = (collectionView.cellForItem(at: selectedIndexPath) as? PhotoCollectionViewCell) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
            }
            //The cell was found successfully
            return guardedCell.frame
        }
    }
    
}

extension ViewController: ZoomAnimatorDelegate {
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        //Get a guarded reference to the cell's UIImageView
        let referenceImageView = getImageViewFromCollectionViewCell(for: selectedIndexPath)
        
        return referenceImageView

    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        view.layoutIfNeeded()
        collectionView.layoutIfNeeded()
        
        //Get a guarded reference to the cell's frame
        let unconvertedFrame = getFrameFromCollectionViewCell(for: selectedIndexPath)
        
        let cellFrame = collectionView.convert(unconvertedFrame, to: view)
        
        if cellFrame.minY < collectionView.contentInset.top {
            return CGRect(x: cellFrame.minX, y: collectionView.contentInset.top, width: cellFrame.width, height: cellFrame.height - (collectionView.contentInset.top - cellFrame.minY))
        }
        
       return cellFrame
    }
    
    
}
